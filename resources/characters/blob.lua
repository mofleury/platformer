local frames = require "frames"

local generator = frames.generator("resources/characters/zerox3.png")

local animations = {
    idle = {
        frame_duration = 0.1,
        generator.frameAt(122, 758, 24, 30),
    }
}

return {
    image = generator.image,
    animations = animations
}
