local collision = {}

function collision.collide(o1, o2)

    local w = 0.5 * (o1.dx + o2.dx);
    local h = 0.5 * (o1.dy + o2.dy);
    local dx = (o1.x + o1.dx / 2) - (o2.x + o2.dx / 2);
    local dy = (o1.y + o1.dy / 2) - (o2.y + o2.dy / 2);

    if (math.abs(dx) <= w and math.abs(dy) <= h) then

        local wy = w * dy;
        local hx = h * dx;

        local details = {}

        if (wy > hx) then

            if (wy > -hx) then
                -- / * collision at the bottom * /
                details.bottom = true
            else
                -- / * on the right * /
                details.right = true
            end
        else
            if (wy > -hx) then
                --  / * on the left * /
                details.left = true
            else
                -- / * at the top * /
                details.top = true
            end
        end

        if (math.abs(math.abs(wy) - math.abs(hx)) <= player.x_speed) then
            -- edge case : we are on a corner, we should say that both egdes collide
            if (wy > 0 and hx > 0) then
                details.bottom = true
                details.left = true
            elseif (wy > 0 and hx < 0) then
                details.bottom = true
                details.right = true
            elseif (wy < 0 and hx > 0) then
                details.top = true
                details.left = true
            elseif (wy < 0 and hx < 0) then
                details.top = true
                details.right = true
            end
        end

        return true, details
    end

    return false, {}
end

return collision