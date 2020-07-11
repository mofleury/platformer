--
--package.path = [[/home/mofleury/.IdeaIC2017.2/config/plugins/Lua/mobdebug/?.lua;]] .. package.path
--require("mobdebug").start()

local levels = require "levels"

levels.debug = false

for seed = 10, 11, 1 do
    local skeleton = levels.generate_skeleton(seed, 4, 10, 5, 5)

    levels.print_skeleton(skeleton)

    local cellBank = levels.resolveCellBank("cells_index")

    local tileMap = levels.buildTileMap(skeleton, "resources/levels/test_cell", cellBank)
    levels.print_tilemap(tileMap)

    print "-------------"
end