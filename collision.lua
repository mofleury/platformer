local collision = {}

function collision.overlap(o1, o2)
    return (o1.x < o2.x + o2.dx and
            o1.x + o1.dx > o2.x and
            o1.y < o2.y + o2.dy and
            o1.dy + o1.y > o2.y)
end

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

--        if (math.abs(math.abs(wy) - math.abs(hx)) <= 200) then
--            -- edge case : we are on a corner, we should say that both egdes collide
--            if (wy > 0 and hx > 0) then
--                details.bottom = true
--                details.left = true
--            elseif (wy > 0 and hx < 0) then
--                details.bottom = true
--                details.right = true
--            elseif (wy < 0 and hx > 0) then
--                details.top = true
--                details.left = true
--            elseif (wy < 0 and hx < 0) then
--                details.top = true
--                details.right = true
--            end
--
--            -- if on a top corner, consider only a collition with bottom
--            if details.bottom then
--                if details.left then
--                    details.left = nii
--                end
--                if details.right then
--                    details.right = nil
--                end
--            end
--        end



        return true, details
    end

    return false, {}
end

--
--local function pointInRectangle(p, rect)
--    return p[1] > rect.x and p[1] < rect.x + rect.dx and
--            p[2] > rect.y and p[2] < rect.y + rect.dy
--end
--
--
--
--function collision.collide(o1, o2)
--    if (o1.x < o2.x + o2.dx and
--            o1.x + o1.dx > o2.x and
--            o1.y < o2.y + o2.dy and
--            o1.dy + o1.y > o2.y) then
--        -- collision, now need to get the details
--
--        local midLeft = { o1.x, o1.y + o1.y / 2 }
--        local midRight = { o1.x + o1.dx, o1.y + o1.y / 2 }
--        local bottomLeft = { o1.x, o1.y }
--        local bottomMid = { o1.x + o1.dx / 2, o1.y }
--        local bottomRight = { o1.x + o1.dx, o1.y }
--        local top = { o1.x + o1.dx / 2, o1.y + o1.dy }
--
--        local details = {}
--
--        if pointInRectangle(top, o2) then
--            details.top = true
--        end
--        if pointInRectangle(midLeft, o2) then
--            details.left = true
--        end
--        if pointInRectangle(midRight, o2) then
--            details.right = true
--        end
--        if pointInRectangle(bottomLeft, o2) or pointInRectangle(bottomMid, o2) or pointInRectangle(bottomRight, o2) then
--            details.bottom = true
--        end
--
--        return true, details
--    else
--        return false, {}
--    end
--end


return collision