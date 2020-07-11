--
--package.path = [[/home/mofleury/.IdeaIC2017.2/config/plugins/Lua/mobdebug/?.lua;]] .. package.path
--require("mobdebug").start()

local levels = require "level_generator/levels"

levels.debug = false

for seed = 10, 11, 1 do
    local skeleton = levels.generate_skeleton(seed, 4, 10, 5, 5)

    levels.print_skeleton(skeleton)
    local cellBank = {}
    cellBank["0000"] = "resources/levels/test_cell"
    cellBank["0001"] = "resources/levels/test_cell"
    cellBank["0010"] = "resources/levels/test_cell"
    cellBank["0011"] = "resources/levels/test_cell"
    cellBank["0100"] = "resources/levels/test_cell"
    cellBank["0101"] = "resources/levels/test_cell"
    cellBank["0110"] = "resources/levels/test_cell"
    cellBank["0111"] = "resources/levels/test_cell"
    cellBank["1000"] = "resources/levels/test_cell"
    cellBank["1001"] = "resources/levels/test_cell"
    cellBank["1010"] = "resources/levels/test_cell"
    cellBank["1011"] = "resources/levels/test_cell"
    cellBank["1100"] = "resources/levels/test_cell"
    cellBank["1101"] = "resources/levels/test_cell"
    cellBank["1110"] = "resources/levels/test_cell"
    cellBank["1111"] = "resources/levels/test_cell"
    local tileMap = levels.buildTileMap(skeleton, "resources/levels/test_cell", cellBank)
    levels.print_tilemap(tileMap)

    print "-------------"
end