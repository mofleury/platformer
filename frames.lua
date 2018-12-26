local JSON = require "JSON"

local frames = {}

function frames.generator(imageFile, jsonFile)

    local jsonSpriteSheet;

    if jsonFile ~= nil then
        local spriteFile = io.open(jsonFile)
        local spriteFileContents = spriteFile:read("*a")
        spriteFile:close()
        jsonSpriteSheet = JSON:decode(spriteFileContents)
    end

    local sourceImage = love.graphics.newImage(imageFile)

    local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
    local image_h = sourceImage:getHeight()


    local function frameAt(x, y, dx, dy, axs, ays)
        local ax = dx / 2
        local ay = 0
        if not (axs == nil) then
            ax = ax + axs
        end
        if not (ays == nil) then
            ay = ay + ays
        end

        return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y = y, ax = ax, ay = ay }
    end

    local function startsWith(str, start)
        return str:sub(1, #start) == start
    end

    local function resolveAnimation(name, duration, alternatives, next, axs, ays)
        local animation = {}
        for i, f in ipairs(jsonSpriteSheet.frames) do
            if (startsWith(f.filename, name .. "/")) then
                local frame = frameAt(f.frame.x, f.frame.y, f.frame.w, f.frame.h, axs, ays)
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

