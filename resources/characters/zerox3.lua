local JSON = require "JSON"

local spriteFile = io.open("resources/characters/atlas/zero.json")
local spriteFileContents = spriteFile:read("*a")
spriteFile:close()
local jsonSpriteSheet = JSON:decode(spriteFileContents)

local sourceImage = love.graphics.newImage("resources/characters/atlas/zero.png")

local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
local image_h = sourceImage:getHeight()


local function quadAt(x, y, dx, dy, ax, ay)

    if ax == nil then
        ax = dx / 2
    end
    if ay == nil then
        ay = dy / 2
    end

    return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y = y, ax = ax, ay = ay }
end

local function startsWith(str, start)
    return str:sub(1, #start) == start
end

local function resolveAnimation(name, duration, alternatives, next)
    local frames = {}
    for i, frame in ipairs(jsonSpriteSheet.frames) do
        if (startsWith(frame.filename, name .. "/")) then
            local quad = quadAt(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h)
            table.insert(frames, quad)
        end
    end
    frames.frame_duration = duration
    frames.alternates = alternatives
    frames.next = next

    return frames
end


local animations = {
    idle = resolveAnimation("idle", 0.1, { shooting = "idle_shooting" }),
    idle_shooting = resolveAnimation("idle-shooting", 0.1),
    running = resolveAnimation("running", 0.05, { shooting = "running_shooting" }),
    running_shooting = resolveAnimation("running-shooting", 0.05),
    jumping = resolveAnimation("jumping", 0.05, { shooting = "jumping_shooting" }),
    jumping_shooting = resolveAnimation("jumping-shooting", 0.05),
    falling = resolveAnimation("falling", 0.05, { shooting = "falling_shooting" }),
    falling_shooting = resolveAnimation("falling-shooting", 0.05),
    landing = resolveAnimation("landing", 0.05, { shooting = "landing_shooting" }, "idle"),
    landing_shooting = resolveAnimation("landing-shooting", 0.05),
    dashing = resolveAnimation("dashing", 0.05, { shooting = "dashing_shooting" }),
    dashing_shooting = resolveAnimation("dashing-shooting", 0.05),
    wall_landing = resolveAnimation("wall-landing", 0.05, nil, "wall_sliding"),
    wall_sliding = resolveAnimation("wall-sliding", 0.05, { shooting = "wall_sliding_shooting" }),
    wall_sliding_shooting = resolveAnimation("wall-sliding-shooting", 0.05),
    wall_jumping = resolveAnimation("wall-jumping", 0.05, { shooting = "wall_jumping_shooting" }, "jumping"),
    wall_jumping_shooting = resolveAnimation("wall-jumping-shooting", 0.05),
    slashing = resolveAnimation("slashing", 0.05, nil, nil)
}


return {
    image = sourceImage,
    animations = animations
}
