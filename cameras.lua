local cameras = {}

function cameras.windowCamera(camera_window, screen, p)

    local camera = {}

    function camera.update(dt)
        if p.x < screen.x + camera_window.x then
            screen.x = p.x - camera_window.x
        elseif p.x + p.dx > screen.x + camera_window.x + camera_window.dx then
            screen.x = p.x + p.dx - (camera_window.x + camera_window.dx)
        end


        if p.y < screen.y + camera_window.y then
            screen.y = p.y - camera_window.y
        elseif p.y + p.dy > screen.y + camera_window.y + camera_window.dy then
            screen.y = p.y + p.dy - (camera_window.y + camera_window.dy)
        end
    end

    function camera.windowBox()
        return { x = screen.x + camera_window.x, y = screen.y + camera_window.y, dx = camera_window.dx, dy = camera_window.dy }
    end

    return camera
end

return cameras
