local sourceImage = love.graphics.newImage("resources/zero_spritesheet.png")

local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
local image_h = sourceImage:getHeight()

local tile_w = 46
local tile_h = 47

local function quadAt(idx)
    return love.graphics.newQuad(1, tile_h * idx + 1, tile_w, tile_h, image_w, image_h)
end


animations = {
    idle = {
        quadAt(12),
        quadAt(13),
        quadAt(14)
    },
    running_start = {
        quadAt(1)
    },
    running = {
        quadAt(2),
        quadAt(3),
        quadAt(4),
        quadAt(5),
        quadAt(6),
        quadAt(7),
        quadAt(8),
        quadAt(9),
        quadAt(10),
        quadAt(11)
    },
}




return {
    image = sourceImage,
    animations = animations
}
