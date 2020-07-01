--
--package.path = [[/home/mofleury/.IdeaIC2017.2/config/plugins/Lua/mobdebug/?.lua;]] .. package.path
--require("mobdebug").start()

local levels = require "levels"

local skeleton = levels.generate_skeleton(250, 10)

levels.print_skeleton(skeleton)
