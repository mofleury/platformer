do
    local sourceImage = love.graphics.newImage("resources/zerox3.png")

    local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
    local image_h = sourceImage:getHeight()


    local function quadAt(x, y, dx, dy)
        return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y = y }
    end


    local animations = {
        idle = {
            quadAt(3, 12, 38, 44),
            quadAt(3, 12, 38, 44),
            quadAt(613, 5, 38, 44),
            quadAt(613, 5, 38, 44),
            quadAt(660, 4, 38, 44),
            quadAt(660, 4, 38, 44),
            quadAt(706, 4, 38, 44),
            quadAt(706, 4, 38, 44),
        },
        running_start = {
            quadAt(48, 12, 46, 44)
        },
        running = {
            quadAt(100, 7, 43, 49),
            quadAt(148, 5, 41, 49),
            quadAt(199, 5, 42, 49),
            quadAt(253, 5, 41, 49),
            quadAt(304, 3, 42, 49),
            quadAt(352, 2, 42, 49),
            quadAt(398, 4, 41, 49),
            quadAt(445, 5, 47, 49),
            quadAt(499, 6, 47, 49),
            quadAt(553, 2, 46, 49)
        },
        jumping = {
            quadAt(4, 406, 40, 55),
            quadAt(52, 403, 40, 55),
            quadAt(95, 402, 40, 55),
            quadAt(142, 402, 40, 55),
            quadAt(191, 401, 40, 55),
            quadAt(238, 390, 42, 69),
            quadAt(282, 390, 40, 69),
            quadAt(327, 392, 40, 55),
        },
        landing = {
            quadAt(327, 392, 40, 55),
            quadAt(371, 397, 40, 44),
        }
    }


    return {
        frame_duration = 0.10,
        image = sourceImage,
        animations = animations
    }
end