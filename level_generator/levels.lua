local levels = {}

levels.debug = false

local probabilities = {}
probabilities.top = 10
probabilities.bottom = probabilities.top + 10
probabilities.left = probabilities.bottom + 30
probabilities.right = probabilities.left + 30

probabilities.total = probabilities.right




function levels.generate()
    print "haha"
end

local function print_node(node, lines, row)
    if (node == nil) then
        lines[row * 3] = lines[row * 3] .. "     "
        lines[row * 3 + 1] = lines[row * 3 + 1] .. "     "
        lines[row * 3 + 2] = lines[row * 3 + 2] .. "     "
    else
        local content = " "
        if (node.type == "begin") then
            content = "b"
        elseif (node.type == "end") then
            content = "e"
        end

        lines[row * 3] = lines[row * 3] .. "." .. (node.top and "| |" or "---") .. ".";
        lines[row * 3 + 1] = lines[row * 3 + 1] .. (node.left and "=" or "|") .. " " .. content .. " " .. (node.right and "=" or "|");
        lines[row * 3 + 2] = lines[row * 3 + 2] .. "." .. (node.bottom and "| |" or "---") .. ".";
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

    if skeleton[y] == nil then
        skeleton[y] = {}
        local top_before = skeleton.y_origin + skeleton.height
        if y < skeleton.y_origin then
            skeleton.y_origin = y
            skeleton.height = top_before - skeleton.y_origin
        else
            -- y is the new top
            skeleton.height = y - skeleton.y_origin + 1
        end
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

local function add_cell(skeleton, remaining, curX, curY, curCell, main)


    local throw = math.random(probabilities.total);
    local newX = curX
    local newY = curY
    local nextCell = {}
    if levels.debug then
        print("-----" .. throw .. " " .. curX .. "-" .. curY .. "-------")
    end
    if levels.debug then print(throw) end
    if (throw <= probabilities.top and curCell.top == nil) then
        curCell.top = true
        newY = newY + 1
        ensure_y(skeleton, newY)
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.bottom = true
    elseif (throw <= probabilities.bottom and curCell.bottom == nil) then
        curCell.bottom = true
        newY = newY - 1
        ensure_y(skeleton, newY)
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.top = true
    elseif (throw <= probabilities.left and curX > 1 and curCell.left == nil) then
        curCell.left = true
        newX = newX - 1
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.right = true
    elseif (throw <= probabilities.right) then
        curCell.right = true
        newX = newX + 1
        ensure_width(skeleton, newX)
        nextCell = get_or_create_next_cell(skeleton, newX, newY)
        nextCell.left = true
    else
        print("oops" .. throw)
    end

    if levels.debug then
        print("-----" .. newX .. "-" .. newY .. "-------")
        levels.print_skeleton(skeleton)
        print("---------------")
    end
    if (remaining == 1) then
        if main then
            nextCell.type = "end"
        end
        return skeleton
    end
    add_cell(skeleton, remaining - 1, newX, newY, nextCell, main)
end

local function add_branch(skeleton, size)
    -- backtrack
    local nextCell
    local newX = 1
    local newY = 1

    while nextCell == nil do
        newX = math.random(1, skeleton.width)
        newY = math.random(skeleton.y_origin, skeleton.y_origin + skeleton.height - 1)
        local slice = skeleton[newY]
        if slice ~= nil then
            nextCell = slice[newX]
        end
    end

    add_cell(skeleton, size, newX, newY, nextCell, false)
end

function levels.generate_skeleton(seed, path_length)

    math.randomseed(seed)

    local skeleton = { y_origin = 1, height = 1, width = 1 }
    skeleton[1] = {}
    local curCell = {}
    skeleton[1][1] = curCell
    curCell.type = "begin"

    add_cell(skeleton, path_length, 1, 1, curCell, true)

    add_branch(skeleton, 5)

    return skeleton
end



return levels

