local frames = require "frames"

local generator = frames.generator("resources/characters/atlas/michael.png",
    "resources/characters/atlas/michael.json",
    nil)

local animations = {
    idle = generator.resolveAnimation("idle", 0.5),
    walking = generator.resolveAnimation("walking", 0.15, nil, nil, frames.gapBasedNextFrameCondition(7))
}


return {
    image = generator.image,
    animations = animations
}
