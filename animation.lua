local animation = {}

function animation.animator(spritesheet)

    local animator = {}

    local state = "running"
    local index = 0

    local time_elapsed = 0

    function animator.draw(o)

        local xDraw
        if (o.orientation == 1) then
            xDraw = o.x
        else
            xDraw = o.x + spritesheet.tile_w
        end
        local xScale
        if (o.orientation == 1) then
            xScale = 1
        else
            xScale = -1
        end

        love.graphics.draw(spritesheet.image, --The image
            --Current frame of the current animation
            spritesheet.animations[state][index + 1],
            xDraw,
            screen.dy - spritesheet.tile_h - o.y,
            0,
            xScale,
            1)
    end

    function animator.update(dt)
        time_elapsed = time_elapsed + dt
        if (time_elapsed > spritesheet.frame_duration) then
            index = (index + 1) % table.getn(spritesheet.animations[state])

            time_elapsed = 0
        end
    end

    return animator
end

return animation