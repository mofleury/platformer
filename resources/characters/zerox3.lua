local sourceImage = love.graphics.newImage("resources/characters/zerox3.png")

local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
local image_h = sourceImage:getHeight()


local function quadAt(x, y, dx, dy, ax, ay)

    if ax == nil then
        ax = dx/2
    end
    if ay == nil then
        ay = dy/2
    end

    return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y = y, ax = ax, ay = ay }
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
        alternates = { shooting = "jumping_shooting" }
    },
    jumping_shooting = {
        frame_duration = 0.05,
        quadAt(0, 519, 60, 67),
        quadAt(60, 519, 60, 67),
        quadAt(120, 519, 60, 67),
        quadAt(180, 519, 60, 67),
        quadAt(240, 519, 60, 67),
    },
    falling = {
        frame_duration = 0.05,
        quadAt(300, 450, 60, 67),
        quadAt(360, 450, 60, 67),
        alternates = { shooting = "falling_shooting" }
    },
    falling_shooting = {
        frame_duration = 0.05,
        quadAt(300, 519, 60, 67),
        quadAt(360, 519, 60, 67),
    },
    landing = {
        frame_duration = 0.05,
        quadAt(420, 466, 60, 51),
        quadAt(480, 474, 60, 43),
        next = "idle",
        alternates = { shooting = "landing_shooting" }
    },
    landing_shooting = {
        frame_duration = 0.05,
        quadAt(420, 535, 60, 51),
        quadAt(480, 543, 60, 43),
    },
    dashing = {
        frame_duration = 0.05,
        quadAt(61, 122, 55, 54),
        quadAt(116, 122, 59, 54),
        quadAt(176, 122, 73, 54),
        quadAt(258, 122, 73, 54),
        quadAt(338, 122, 86, 54),
        quadAt(425, 122, 86, 54),
        alternates = { shooting = "dashing_shooting" }
    },
    dashing_shooting = {
        frame_duration = 0.05,
        quadAt(61, 176, 55, 54),
        quadAt(116, 176, 59, 54),
        quadAt(176, 176, 73, 54),
        quadAt(258, 176, 73, 54),
        quadAt(338, 176, 86, 54),
        quadAt(425, 176, 86, 54),
    },
    wall_landing = {
        frame_duration = 0.05,
        quadAt(328, 598, 61, 51),
        quadAt(328, 654, 61, 51),
        quadAt(328, 716, 61, 51),
        next = "wall_sliding"
    },
    wall_sliding = {
        frame_duration = 0.05,
        quadAt(418, 598, 43, 49),
        alternates = { shooting = "wall_sliding_shooting" }
    },
    wall_sliding_shooting = {
        frame_duration = 0.05,
        quadAt(466, 598, 43, 49)
    },
    wall_jumping = {
        frame_duration = 0.05,
        quadAt(520, 596, 43, 51),
        quadAt(562, 596, 43, 51),
        next = "jumping",
        alternates = { shooting = "wall_jumping_shooting" }
    },
    wall_jumping_shooting = {
        frame_duration = 0.05,
        quadAt(520, 596, 43, 51),
        quadAt(606, 596, 45, 51),
    },
    slashing = {
        frame_duration = 0.05,
        quadAt(37, 234, 110, 68),
        quadAt(147, 234, 110, 68),
        quadAt(257, 234, 110, 68),
        quadAt(367, 234, 110, 68),
        quadAt(477, 234, 110, 68),
        quadAt(586, 234, 112, 68),
        quadAt(698, 234, 108, 68),
        quadAt(807, 234, 110, 68),
        quadAt(917, 234, 110, 68),
        quadAt(1027, 234, 110, 68),
        quadAt(1137, 234, 110, 68),
        -- quadAt(1247, 234, 110, 68), this last frame does not look so good
        quadAt(1247, 166, 110, 68),
        next = idle
    }
}


return {
    image = sourceImage,
    animations = animations
}
