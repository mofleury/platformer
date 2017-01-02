local tiles = {}


local function loadTileSet(rawTilesets, root, mapWidth, mapHeight)
    local tileset = {}

    for i, ts in ipairs(rawTilesets) do

        local tilesetImage = love.graphics.newImage(root .. "/" .. ts.image)

        local spriteBatch = love.graphics.newSpriteBatch(tilesetImage, mapWidth * mapHeight)

        local image_w = tilesetImage:getWidth() --or SourceImage.getWidth(SourceImage)
        local image_h = tilesetImage:getHeight()

        local function quadAt(x, y, dx, dy)
            return love.graphics.newQuad(x, y, dx, dy, image_w, image_h)
        end

        local gid = ts.firstgid

        for h = 0, ts.imageheight / ts.tileheight - 1, 1 do
            for w = 0, ts.imagewidth / ts.tilewidth - 1, 1 do

                tileset[gid] = {
                    quad = quadAt(ts.margin + w * (ts.tilewidth + ts.spacing),
                        ts.margin + h * (ts.tileheight + ts.spacing),
                        ts.tilewidth, ts.tileheight),
                    image = tilesetImage,
                    spriteBatch = spriteBatch
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


function tiles.tilemap(tilemap, root, screen)

    local map = {}

    local raw = require(tilemap)

    local tilewidth = raw.tilewidth
    local tileheight = raw.tileheight
    local spriteBatches = {}
    local layers = {}

    local tileset = loadTileSet(raw.tilesets, root, raw.width, raw.height)

    for i, l in ipairs(raw.layers) do
        layers[l.name] = loadLayer(l)
    end


    map.obstacles = {}
    for w, slice in pairs(layers.solid) do
        for h, gid in pairs(slice) do
            table.insert(map.obstacles, { x = (w - 1) * tilewidth, y = (h - 2) * tileheight, dx = tilewidth, dy = tileheight })
        end
    end


    local function updateSpriteBatches()
        for sb, u in pairs(spriteBatches) do
            sb:clear()
        end

        for n, l in pairs(layers) do
            for w, slice in pairs(l) do
                for h, gid in pairs(slice) do

                    local sb = tileset[gid].spriteBatch

                    sb:add(tileset[gid].quad, (w - 1) * tilewidth, screen.dy - (h - 1) * tileheight)

                    spriteBatches[sb] = 1
                end
            end
        end
    end

    updateSpriteBatches()

    function map.draw()
        for sb, u in pairs(spriteBatches) do
            love.graphics.draw(sb, 0, 0)
        end
    end


    return map
end

return tiles