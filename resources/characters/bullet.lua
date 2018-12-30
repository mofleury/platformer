local frames = require "frames"

local generator = frames.generator("resources/characters/zerox3.png")

local animations = {
    idle = {
        generator.frameAt(16, 684, 8, 6),
        nextFrameCondition = frames.timeBasedNextFrameCondition(0.1)
    }
}

return {
    image = generator.image,
    animations = animations
}
