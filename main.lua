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

local states = require("states")

function love.load()

    love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
    states:add("fishing", require("fishingview"))
    states:add("message", require("messageview"))
    states:add("debug map", require("debugmapview"))

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

function love.draw()

    states:draw()

end
