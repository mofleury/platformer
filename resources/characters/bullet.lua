local frames = require "frames"

local generator = frames.generator("resources/characters/zerox3.png")

local animations = {
    idle = {
        frame_duration = 0.1,
        generator.frameAt(16, 684, 8, 6)
    }
}

return {
    image = generator.image,
    animations = animations
}
