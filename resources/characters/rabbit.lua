local frames = require "frames"

local generator = frames.generator("resources/characters/atlas/rabbit.png",
    "resources/characters/atlas/rabbit.json",
    "resources/characters/atlas/rabbit-actions.json")

local animations = {
    idle = generator.resolveAnimation("idle", 0.1),
    jumping = generator.resolveAnimation("jumping", 0.15, nil, "falling"),
    falling = generator.resolveAnimation("falling", 0.15),
    landing = generator.resolveAnimation("landing", 0.15, nil, "idle")
}


return {
    image = generator.image,
    animations = animations
}
