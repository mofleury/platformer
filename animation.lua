local animation = {}

local animation_slowdown_factor = 1

function animation.animator(spritesheet, object)

    local animator = {}

    local index = 0

    local previous_state = object.state
    local time_elapsed = 0

    function animator.draw()
        debug_data.index = index

        local xDraw
        if (object.orientation == 1) then
            xDraw = object.x
        else
            xDraw = object.x + spritesheet.animations[object.state][index + 1].dy
        end
        local xScale
        if (object.orientation == 1) then
            xScale = 1
        else
            xScale = -1
        end

        love.graphics.draw(spritesheet.image, --The image
            --Current frame of the current animation
            spritesheet.animations[object.state][index + 1].q,
            xDraw,
            screen.dy - spritesheet.animations[object.state][index + 1].dy - object.y,
            0,
            xScale,
            1)

        debug_data.sprite = spritesheet.animations[object.state][index + 1]
    end

    function animator.update(dt)
        if (object.state ~= previous_state) then
            index = 0
            time_elapsed = 0
            previous_state = object.state
        end

        time_elapsed = time_elapsed + dt
        if (time_elapsed > spritesheet.frame_duration * animation_slowdown_factor) then
            index = (index + 1) % table.getn(spritesheet.animations[object.state])

            time_elapsed = 0
        end
    end

    return animator
end

return animation