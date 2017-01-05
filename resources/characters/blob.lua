local sourceImage = love.graphics.newImage("resources/characters/zerox3.png")

local image_w = sourceImage:getWidth() --or SourceImage.getWidth(SourceImage)
local image_h = sourceImage:getHeight()


local function quadAt(x, y, dx, dy)
    return { q = love.graphics.newQuad(x, y, dx, dy, image_w, image_h), dx = dx, dy = dy, x = x, y = y }
end


local animations = {
    idle = {
        frame_duration = 0.1,
        quadAt(843, 152, 24, 30),
    }
}


return {
    image = sourceImage,
    animations = animations
}
