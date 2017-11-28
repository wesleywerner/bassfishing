--[[
   fishingview.lua

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

local module = {}
local glob = require("globals")
local genie = require("lakegenerator")
local states = require("states")
local player = require("player")
local maprender = require("maprender")

local drawoffset = {x=0, y=0}
local mapstep = 16 * 3

function module:init()

    -- create a new map on the global module.
    if not glob.lake then
        glob.lake = genie:generate(glob.defaultMapWidth,
        glob.defaultMapHeight, glob.defaultMapSeed,
        glob.defaultMapDensity, glob.defaultMapIterations)
    
        player:launchBoat()
    end

end

function module:keypressed(key)
    if key == "escape" then
        states:pop()
    elseif key == "f10" then
        states:push("debug map")
    elseif key == "w" then
        drawoffset.y = math.min(0, drawoffset.y + mapstep)
    elseif key == "s" then
        drawoffset.y = drawoffset.y - mapstep
    elseif key == "a" then
        drawoffset.x = math.min(0, drawoffset.x + mapstep)
    elseif key == "d" then
        drawoffset.x = drawoffset.x - mapstep
    end
end

function module:update(dt)

end

function module:draw()

    maprender:render()
    love.graphics.setColor(255, 255, 255)
    --love.graphics.scale(2, 2)
    love.graphics.draw(maprender.image, drawoffset.x, drawoffset.y)

end

return module
