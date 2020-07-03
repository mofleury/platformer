--
--package.path = [[/home/mofleury/.IdeaIC2017.2/config/plugins/Lua/mobdebug/?.lua;]] .. package.path
--require("mobdebug").start()

local levels = require "levels"

levels.debug = false

for seed = 1, 10, 1 do
    local skeleton = levels.generate_skeleton(seed, 4, 10, 5, 5)

    levels.print_skeleton(skeleton)

    print "-------------"
end