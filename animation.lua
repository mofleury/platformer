local animation= {}

function animation.animator(spritesheet)

    local state = "running"
    local index = 0

    local time_elapsed = 0

    local draw = function(x, y)
        love.graphics.draw(spritesheet.image, --The image
            --Current frame of the current animation
            spritesheet.animations[state][index + 1],
            x,
            screen.dy - spritesheet.tile_h - y)
    end

    local update = function(dt)
        time_elapsed = time_elapsed + dt
        if (time_elapsed > spritesheet.frame_duration) then
            index = (index + 1) % table.getn(spritesheet.animations[state])

            time_elapsed = 0
        end
    end

    return {
        draw = draw,
        update = update
    }
end

return animation