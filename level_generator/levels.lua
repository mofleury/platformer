local levels = {}

local debug = true

function levels.generate()
    print "haha"
end

local function print_node(node, lines, row)
    if (node == nil) then
        lines[row * 3] = lines[row * 3] .. "     "
        lines[row * 3 + 1] = lines[row * 3 + 1] .. "     "
        lines[row * 3 + 2] = lines[row * 3 + 2] .. "     "
    else
        lines[row * 3] = lines[row * 3] .. "|-" .. (node.top and " " or "-") .. "-|";
        lines[row * 3 + 1] = lines[row * 3 + 1] .. (node.left and "=" or "|") .. "   " .. (node.right and "=" or "|");
        lines[row * 3 + 2] = lines[row * 3 + 2] .. "|-" .. (node.bottom and " " or "-") .. "-|";
    end
end

function levels.print_skeleton(skeleton)


    local lines = {}

    local bottom = skeleton.y_origin
    local top = skeleton.y_origin + skeleton.height - 1

    for h = bottom, top, 1 do
        lines[h * 3] = ""
        lines[h * 3 + 1] = ""
        lines[h * 3 + 2] = ""
    end

    for h = bottom, top, 1 do
        for w = 1, skeleton.width, 1 do
            local slice = skeleton[h];
            if slice ~= nil then
                local node = slice[w]
                print_node(node, lines, h)
            end
        end
    end

    for h = top, bottom, -1 do
        print(lines[h * 3])
        print(lines[h * 3 + 1])
        print(lines[h * 3 + 2])
    end
end


local function ensure_y(skeleton, y)
    if (skeleton.height < y) then
        for h = skeleton.height + 1, y, 1 do
            skeleton[h] = {}
        end
        skeleton.height = y
    elseif (y < skeleton.y_origin) then
        local diff = skeleton.y_origin - y
        for h = y, skeleton.y_origin - 1, 1 do
            skeleton[h] = {}
        end
        skeleton.y_origin = y
        skeleton.height = skeleton.height + diff
    end
end

local function ensure_width(skeleton, width)
    if (skeleton.width < width) then
        skeleton.width = width
    end
end

local function get_or_create_next_cell(skeleton, newX, newY)
    local nextCell = skeleton[newY][newX]
    if nextCell == nil then
        nextCell = {}
        skeleton[newY][newX] = nextCell
    end
    return nextCell
end

local function add_cell(skeleton, remaining, curX, curY, curCell)
    local throw = math.random(5);
    local newX = curX
    local newY = curY
    local nextCell = {}
    if debug then print(throw) end
    if (throw <= 1 and curCell.top == nil) then
        curCell.top = true
        newY = newY + 1
        ensure_y(skeleton, newY)
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.bottom = true
    elseif (throw <= 2 and curCell.bottom == nil) then
        curCell.bottom = true
        newY = newY - 1
        ensure_y(skeleton, newY)
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.top = true
    elseif (throw <= 3 and curX > 1 and curCell.left == nil) then
        curCell.left = true
        newX = newX - 1
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.right = true
    elseif (throw <= 4) then
        curCell.right = true
        newX = newX + 1
        ensure_width(skeleton, newX)
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.left = true
    else
        -- backtrack
        nextCell = nil
        while nextCell == nil do
            newX = math.random(1, skeleton.width)
            newY = math.random(skeleton.y_origin, skeleton.y_origin + skeleton.height - 1)
            local slice = skeleton[newY]
            if slice ~= nil then
                nextCell = slice[newX]
            end
        end
        remaining = remaining + 1 -- backtrack does not create a cell
        if debug then print("backtrack") end
    end

    if debug then
        levels.print_skeleton(skeleton)
        print("---------------")
    end
    if (remaining == 1) then
        return skeleton
    end
    add_cell(skeleton, remaining - 1, newX, newY, nextCell)
end

function levels.generate_skeleton(seed, path_length)

    math.randomseed(seed)

    local skeleton = { y_origin = 1, height = 1, width = 1 }
    skeleton[1] = {}
    local curCell = {}
    skeleton[1][1] = curCell

    add_cell(skeleton, path_length, 1, 1, curCell)

    return skeleton
end



return levels

