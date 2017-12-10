--[[
   main.lua

   Copyright 2017 wesley werner <wesley.werner@gmail.com>

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see http://www.gnu.org/licenses/.

]]--

game = require("game")

function love.load()

    love.window.setMode(game.window.width, game.window.height)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    game.states:add("lake selection", require("states.lake-selection"))
    game.states:add("development", require("states.development"))
    game.states:add("messagebox", require("states.messagebox"))
    game.states:add("lakegen development", require("states.lakegen-development"))
    game.states:add("weigh in", require("states.weigh-in"))
    game.states:add("tournament results", require("states.tournament-results"))
    game.states:add("tackle", require("states.tackle"))

end

function love.update(dt)

    game.states:update(dt)

end

function love.keypressed(key)

    game.states:keypressed(key)

end

function love.mousemoved( x, y, dx, dy, istouch )

    game.states:mousemoved( x, y, dx, dy, istouch )

end

function love.mousepressed( x, y, button, istouch )

    game.states:mousepressed( x, y, button, istouch )

end

function love.draw()

    game.states:draw()

end
