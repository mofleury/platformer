local animation = {}

function animation.animator(spritesheet, object, screen)

    local animator = {}

    local index = 0

    local previous_state = object.state
    local time_elapsed = 0

    local drawAnchor = { x = 0, y = 0 }

    local function currentAnimation()

        local animations = spritesheet.animations[object.state];
        if animations == nil then
            println(object.state)
        end
        if animations.alternates ~= nil then
            for n, a in pairs(animations.alternates) do
                if object.subState[n] == true then
                    animations = spritesheet.animations[a]
                end
            end
        end
        return animations
    end

    function animator.currentFrame()
        return currentAnimation()[index + 1]
    end

    function animator.draw()

        local frame = object.frame
        if frame == nil then
            frame = currentAnimation()[index + 1]
            object.frame = frame
        end

        local xCenter = drawAnchor.x + object.dx / 2

        local xDraw = xCenter - frame.anchor.x
        local yDraw = drawAnchor.y + frame.dy - frame.anchor.y
        local xScale

        if (object.orientation == 1) then
            xScale = 1
        else
            xScale = -1
            xDraw = xDraw + frame.dx
        end

        love.graphics.draw(spritesheet.image, --The image
            --Current frame of the current animation
            object.frame.q,
            xDraw - screen.x,
            screen.y + screen.dy - yDraw,
            0,
            xScale,
            1)
    end

    function animator.update(dt)
        if (object.state ~= previous_state) then

            -- if state is the next state of the "current", keep it
            if previous_state ~= nil and spritesheet.animations[object.state].next == previous_state then
                object.state = previous_state
            else
                index = 0
                time_elapsed = 0
                previous_state = object.state
            end
        end

        local anim = currentAnimation()
        local nonAlternateAnim = spritesheet.animations[object.state]

        local nextFrameCondition = anim.nextFrameCondition

        time_elapsed = time_elapsed + dt
        if nextFrameCondition(time_elapsed, drawAnchor, object) then


            index = (index + 1) % table.getn(anim)

            if index == 0 then
                if nonAlternateAnim.next ~= nil then
                    object.state = nonAlternateAnim.next
                    previous_state = nonAlternateAnim.next
                end
            end

            time_elapsed = 0
        end

        object.frame = currentAnimation()[index + 1]
    end

    return animator
end

return animation