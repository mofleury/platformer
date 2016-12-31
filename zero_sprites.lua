do
    local sourceImage = love.graphics.newImage("resources/zerox3.png")

    local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
    local image_h = sourceImage:getHeight()


    local function quadAt(x, y, dx, dy)
        return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y = y }
    end


    local animations = {
        idle = {
            frame_duration = 0.1,
            quadAt(3, 9, 38, 45),
            quadAt(43, 9, 38, 45),
            quadAt(82, 9, 38, 45),
            quadAt(121, 9, 38, 45),
        },
        running = {
            frame_duration = 0.05,
            quadAt(224, 7, 60, 47),
            quadAt(284, 7, 60, 47),
            quadAt(344, 7, 60, 47),
            quadAt(404, 7, 60, 47),
            quadAt(464, 7, 60, 47),
            quadAt(524, 7, 60, 47),
            quadAt(584, 7, 60, 47),
            quadAt(644, 7, 60, 47),
            quadAt(704, 7, 60, 47),
            quadAt(764, 7, 60, 47)
        },
        jumping = {
            frame_duration = 0.05,
            quadAt(0, 392, 60, 67),
            quadAt(60, 392, 60, 67),
            quadAt(120, 392, 60, 67),
            quadAt(180, 392, 60, 67),
            quadAt(240, 392, 60, 67),
        },
        falling = {
            frame_duration = 0.05,
            quadAt(300, 392, 60, 67),
            quadAt(360, 392, 60, 67),
        },
        landing = {
            frame_duration = 0.05,
            quadAt(420, 408, 60, 51),
            quadAt(480, 416, 60, 43),
            next = "idle"
        },
        dashing = {
            frame_duration = 0.05,
            --           quadAt(0, 67, 59, 51),
            quadAt(61, 67, 48, 51),
            quadAt(111, 67, 58, 51),
            quadAt(170, 67, 68, 51),
            quadAt(239, 67, 68, 51),
            quadAt(311, 67, 78, 51),
            quadAt(407, 67, 78, 51),
        },
        wall_landing = {
            frame_duration = 0.05,
            quadAt(323, 474, 39, 50),
            quadAt(378, 474, 34, 50),
            next = "wall_sliding"
        },
        wall_sliding = {
            frame_duration = 0.05,
            quadAt(423, 474, 39, 50)
        },
        wall_jumping = {
            frame_duration = 0.05,
            quadAt(520, 467, 44, 52),
            quadAt(562, 467, 44, 52),
            next = "jumping"

        }
    }


    return {
        image = sourceImage,
        animations = animations
    }
end
