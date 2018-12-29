local JSON = require "JSON"

local frames = {}

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
            anchor = complement.anchor
            attackbox = complement.attackbox
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

    local function resolveAnimation(name, duration, alternatives, next)
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
        animation.frame_duration = duration
        animation.alternates = alternatives
        animation.next = next

        return animation
    end


    return {
        image = sourceImage,
        frameAt = frameAt,
        resolveAnimation = resolveAnimation
    }
end

return frames

