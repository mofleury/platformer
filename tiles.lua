local tiles = {}


local function loadTileSet(rawTilesets, root)
    local tileset = {}

    for i, ts in ipairs(rawTilesets) do

        local tilesetImage = love.graphics.newImage(root .. "/" .. ts.image)

        local image_w = tilesetImage:getWidth() --or SourceImage.getWidth(SourceImage)
        local image_h = tilesetImage:getHeight()

        local function quadAt(x, y, dx, dy)
            return love.graphics.newQuad(x, y, dx, dy, image_w, image_h)
        end

        local gid = ts.firstgid

        for h = 0, ts.imageheight / ts.tileheight-1, 1 do
            for w = 0, ts.imagewidth / ts.tilewidth-1, 1 do

                tileset[gid] = {
                    quad = quadAt(ts.margin + w * (ts.tilewidth + ts.spacing),
                        ts.margin + h * (ts.tileheight + ts.spacing),
                        ts.tilewidth, ts.tileheight),
                    image = tilesetImage
                }

                gid = gid + 1
            end
        end
    end

    return tileset
end

local function loadLayer(rawLayer)
    local layer = {}

    for w = 1, rawLayer.width + 1, 1 do
        layer[w] = {}
        for ih = 0, rawLayer.height - 1, 1 do

            local h = rawLayer.height - ih

            local gid = rawLayer.data[(ih - 1) * rawLayer.width + w]

            if gid ~= 0 then
                layer[w][h] = gid
            end
        end
    end

    return layer
end

local function drawTile(screen, tileset, gid, x, y)

    local tile = tileset[gid]

    love.graphics.draw(tile.image,
        tile.quad,
        x,
        screen.dy - y,
        0,
        1,
        1)
end



function tiles.tilemap(tilemap, root, screen)

    local map = {}

    local raw = require(tilemap)

    local tilewidth = raw.tilewidth
    local tileheight = raw.tileheight

    local tileset = loadTileSet(raw.tilesets, root)
    local layers = {}
    for i, l in ipairs(raw.layers) do
        layers[l.name] = loadLayer(l)
    end


    function map.draw()
        for n, l in pairs(layers) do
            for w, slice in ipairs(l) do
                for h, gid in ipairs(slice) do
                    drawTile(screen, tileset, gid, (w - 1) * tilewidth, (h - 1) * tileheight)
                end
            end
        end
    end


    return map
end

return tiles