local minimap = {}



function minimap.minimap(screen, camera_window, map, players, location, scale_factor)

    local minimap = {}

    local function drawBox(b)
        love.graphics.rectangle('line', b.x - screen.x, screen.dy - (b.y + b.dy - screen.y), b.dx, b.dy)
    end

    local function drawMiniBox(o)
        local b = { x = location.x + o.x / scale_factor, y = location.y + o.y / scale_factor, dx = o.dx / scale_factor, dy = o.dy / scale_factor }
        love.graphics.rectangle('line', b.x, screen.dy - b.y + b.dy, b.dx, b.dy)
    end

    function minimap.update(dt)
    end

    function minimap.draw()

        for i, o in ipairs(map.obstacles) do
            drawMiniBox(o)
        end

        for i, p in ipairs(players) do
            drawMiniBox(p)
        end
    end


    return minimap
end

return minimap
