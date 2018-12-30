local JSON = require "JSON"

local frames = {}

function frames.timeBasedNextFrameCondition(frameDuration)
    return function(time_elapsed, drawAnchor, object)
        drawAnchor.x = object.x
        drawAnchor.y = object.y

        return time_elapsed > frameDuration
    end
end

function frames.gapBasedNextFrameCondition(gap)
    return function(time_elapsed, drawAnchor, object)
        if drawAnchor.x == nil or object.x == nil then
            return true
        end

        drawAnchor.y = object.y

        local shouldSwitch = math.abs(drawAnchor.x - object.x) >= gap

        if shouldSwitch then
            drawAnchor.x = object.x
        end

        return shouldSwitch
    end
end

function frames.generator(imageFile, jsonFile, complementaryJsonFile)

    local jsonSpriteSheet
    local complementaryData

    if jsonFile ~= nil then
        local spriteFile = io.open(jsonFile)
        local spriteFileContents = spriteFile:read("*a")
        spriteFile:close()
        jsonSpriteSheet = JSON:decode(spriteFileContents)
    end


    if complementaryJsonFile ~= nil then
        local file = io.open(complementaryJsonFile)
        local fileContents = file:read("*a")
        file:close()
        complementaryData = JSON:decode(fileContents)
    end

    local sourceImage = love.graphics.newImage(imageFile)

    local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
    local image_h = sourceImage:getHeight()


    local function frameAt(x, y, dx, dy, complement)

        local anchor = {}
        local attackbox
        if complement ~= nil then
            if complement.anchor ~= nil then
                anchor = complement.anchor
            end
            if complement.attackbox ~= nil then
                attackbox = complement.attackbox
            end
        end

        if anchor.x == nil then
            anchor.x = dx / 2
        end
        if anchor.y == nil then
            anchor.y = 0
        end

        return {
            q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h),
            dx = dx,
            dy = dy,
            x = x,
            y = y,
            anchor = anchor,
            attackbox = attackbox
        }
    end

    local function startsWith(str, start)
        return str:sub(1, #start) == start
    end

    local function resolveAnimation(name, duration, alternatives, next, nextFrameCondition)
        local animation = {}

        for i, f in ipairs(jsonSpriteSheet.frames) do
            if (startsWith(f.filename, name .. "/")) then
                local complement
                if complementaryData ~= nil then
                    complement = complementaryData[f.filename]
                end
                local frame = frameAt(f.frame.x, f.frame.y, f.frame.w, f.frame.h, complement)
                table.insert(animation, frame)
            end
        end
        animation.alternates = alternatives
        animation.next = next

        if nextFrameCondition == nil then
            nextFrameCondition = frames.timeBasedNextFrameCondition(duration)
        end
        animation.nextFrameCondition = nextFrameCondition

        return animation
    end


    return {
        image = sourceImage,
        frameAt = frameAt,
        resolveAnimation = resolveAnimation
    }
end

return frames

