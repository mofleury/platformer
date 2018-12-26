local frames = require "frames"

local generator = frames.generator("resources/characters/atlas/zero.png", "resources/characters/atlas/zero.json")

local animations = {
    idle = generator.resolveAnimation("idle", 0.1, { shooting = "idle_shooting" }),
    idle_shooting = generator.resolveAnimation("idle-shooting", 0.1),
    running = generator.resolveAnimation("running", 0.05, { shooting = "running_shooting" }),
    running_shooting = generator.resolveAnimation("running-shooting", 0.05),
    jumping = generator.resolveAnimation("jumping", 0.05, { shooting = "jumping_shooting" }),
    jumping_shooting = generator.resolveAnimation("jumping-shooting", 0.05),
    falling = generator.resolveAnimation("falling", 0.05, { shooting = "falling_shooting" }),
    falling_shooting = generator.resolveAnimation("falling-shooting", 0.05),
    landing = generator.resolveAnimation("landing", 0.05, { shooting = "landing_shooting" }, "idle"),
    landing_shooting = generator.resolveAnimation("landing-shooting", 0.05),
    dashing = generator.resolveAnimation("dashing", 0.05, { shooting = "dashing_shooting" }),
    dashing_shooting = generator.resolveAnimation("dashing-shooting", 0.05),
    wall_landing = generator.resolveAnimation("wall-landing", 0.05, nil, "wall_sliding"),
    wall_sliding = generator.resolveAnimation("wall-sliding", 0.05, { shooting = "wall_sliding_shooting" }),
    wall_sliding_shooting = generator.resolveAnimation("wall-sliding-shooting", 0.05),
    wall_jumping = generator.resolveAnimation("wall-jumping", 0.05, { shooting = "wall_jumping_shooting" }, "jumping"),
    wall_jumping_shooting = generator.resolveAnimation("wall-jumping-shooting", 0.05),
    slashing = generator.resolveAnimation("slashing", 0.05, { airborne = "jumping_slashing" }, nil, nil, -9),
    jumping_slashing = generator.resolveAnimation("jumping-slashing", 0.05, nil, nil, nil, nil)
}


return {
    image = generator.image,
    animations = animations
}
