do
    local sourceImage = love.graphics.newImage("resources/zerox3.png")

    local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
    local image_h = sourceImage:getHeight()


    local function quadAt(x, y, dx, dy)
        return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y= y }
    end


    local animations = {
        idle = {
            quadAt(3, 12, 38, 44),
        },
        running_start = {
            quadAt(48, 12, 46, 44)
        },
        running = {
            quadAt(100, 10, 43, 44),
            quadAt(148, 9, 41, 46),
            quadAt(199, 9, 42, 44),
            quadAt(253, 8, 41, 43),
            quadAt(304, 9, 42, 43),
            quadAt(352, 7, 42, 49),
            quadAt(398, 8, 41, 45),
            quadAt(445, 9, 47, 45),
            quadAt(499, 5, 47, 49),
            quadAt(553, 7, 46, 49)
        },
    }


    return {
        frame_duration = 0.10,
        image = sourceImage,
        animations = animations
    }
end