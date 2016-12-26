local animation = {}

local animation_slowdown_factor = 1

function animation.animator(spritesheet, object)

    local animator = {}

    local index = 0

    local previous_state = object.state
    local time_elapsed = 0

    function animator.draw()
        anim_debug_data.index = index


        local frame = spritesheet.animations[object.state][index + 1]


        local xCenter = object.x + object.dx / 2
        local yCenter = object.y + object.dy / 2

        local xDraw = xCenter - frame.dx / 2
        local yDraw = yCenter + frame.dy / 2

        local xScale
        if (object.orientation == 1) then
            xScale = 1
        else
            xScale = -1
            xDraw = xDraw + frame.dx
        end

        love.graphics.draw(spritesheet.image, --The image
            --Current frame of the current animation
            spritesheet.animations[object.state][index + 1].q,
            xDraw,
            screen.dy - yDraw,
            0,
            xScale,
            1)

        anim_debug_data.sprite = frame
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