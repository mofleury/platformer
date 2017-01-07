local sourceImage = love.graphics.newImage("resources/characters/zerox3.png")

local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
local image_h = sourceImage:getHeight()


local function quadAt(x, y, dx, dy)
    return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y = y }
end


local animations = {
    idle = {
        frame_duration = 0.1,
        quadAt(0, 9, 56, 45),
        quadAt(56, 9, 56, 45),
        quadAt(112, 9, 56, 45),
        quadAt(169, 9, 54, 45),
        alternates = { shooting = "idle_shooting" }
    },
    idle_shooting = {
        frame_duration = 0.1,
        quadAt(0, 63, 56, 45),
        quadAt(0, 63, 56, 45),
        quadAt(112, 63, 56, 45),
        quadAt(169, 63, 54, 45),
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
        quadAt(764, 7, 60, 47),
        alternates = { shooting = "running_shooting" }
    },
    running_shooting = {
        frame_duration = 0.05,
        quadAt(224, 59, 60, 47),
        quadAt(284, 59, 60, 47),
        quadAt(344, 59, 60, 47),
        quadAt(404, 59, 60, 47),
        quadAt(464, 59, 60, 47),
        quadAt(524, 59, 60, 47),
        quadAt(584, 59, 60, 47),
        quadAt(644, 59, 60, 47),
        quadAt(704, 59, 60, 47),
        quadAt(764, 59, 60, 47)
    },
    jumping = {
        frame_duration = 0.05,
        quadAt(0, 450, 60, 67),
        quadAt(60, 450, 60, 67),
        quadAt(120, 450, 60, 67),
        quadAt(180, 450, 60, 67),
        quadAt(240, 450, 60, 67),
    },
    falling = {
        frame_duration = 0.05,
        quadAt(300, 450, 60, 67),
        quadAt(360, 450, 60, 67),
    },
    landing = {
        frame_duration = 0.05,
        quadAt(420, 466, 60, 51),
        quadAt(480, 474, 60, 43),
        next = "idle"
    },
    dashing = {
        frame_duration = 0.05,
        --           quadAt(0, 67, 59, 51),
        quadAt(61, 125, 48, 51),
        quadAt(111, 125, 58, 51),
        quadAt(170, 125, 68, 51),
        quadAt(239, 125, 68, 51),
        quadAt(311, 125, 78, 51),
        quadAt(407, 125, 78, 51),
    },
    wall_landing = {
        frame_duration = 0.05,
        quadAt(323, 532, 39, 50),
        quadAt(378, 532, 34, 50),
        next = "wall_sliding"
    },
    wall_sliding = {
        frame_duration = 0.05,
        quadAt(423, 532, 39, 50)
    },
    wall_jumping = {
        frame_duration = 0.05,
        quadAt(520, 525, 44, 52),
        quadAt(562, 525, 44, 52),
        next = "jumping"
    }
}


return {
    image = sourceImage,
    animations = animations
}
