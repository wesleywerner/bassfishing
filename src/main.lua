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

local states = require("logic.states")
local gamewidth, gameheight = 800, 600


function love.load()

    love.window.setMode( gamewidth, gameheight )
    love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
    states:add("development", require("states.development"))
    states:add("messagebox", require("states.messagebox"))
    states:add("lakegen development", require("states.lakegen-development"))

end

function love.update(dt)

    states:update(dt)

end

function love.keypressed(key)

    states:keypressed(key)

end

function love.mousemoved( x, y, dx, dy, istouch )

    states:mousemoved( x, y, dx, dy, istouch )

end

function love.mousepressed( x, y, button, istouch )

    states:mousepressed( x, y, button, istouch )

end

function love.draw()

    states:draw()

end
