local frames = require "frames"

local generator = frames.generator("resources/characters/atlas/walker.png",
    "resources/characters/atlas/walker.json",
    nil)

local animations = {
    idle = generator.resolveAnimation("idle", 0.1),
    walking = generator.resolveAnimation("walking", 0.15, nil, nil, frames.gapBasedNextFrameCondition(7))
}


return {
    image = generator.image,
    animations = animations
}
