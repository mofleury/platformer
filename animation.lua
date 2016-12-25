local animation = {}

function animation.animator(spritesheet, object)

    local animator = {}

    local index = 0

    local previous_state = object.state
    local time_elapsed = 0

    function animator.draw()

        local xDraw
        if (object.orientation == 1) then
            xDraw = object.x
        else
            xDraw = object.x + spritesheet.tile_w
        end
        local xScale
        if (object.orientation == 1) then
            xScale = 1
        else
            xScale = -1
        end

        love.graphics.draw(spritesheet.image, --The image
            --Current frame of the current animation
            spritesheet.animations[object.state][index + 1],
            xDraw,
            screen.dy - spritesheet.tile_h - object.y,
            0,
            xScale,
            1)
    end

    function animator.update(dt)
        if (object.state ~= previous_state) then
            index = 0
            time_elapsed = 0
            previous_state = object.state
        end

        time_elapsed = time_elapsed + dt
        if (time_elapsed > spritesheet.frame_duration) then
            index = (index + 1) % table.getn(spritesheet.animations[object.state])

            time_elapsed = 0
        end
    end

    return animator
end

return animation