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
local camera = require("camera")
local maprender = require("maprender")

local mapstep = 16 * 10

function module:init()

    -- create a new map on the global module.
    if not glob.lake then
        glob.lake = genie:generate(glob.defaultMapWidth,
        glob.defaultMapHeight, glob.defaultMapSeed,
        glob.defaultMapDensity, glob.defaultMapIterations)
    
        player:launchBoat()
        camera:frame(100, 100, 300, 300)
    end

end

function module:keypressed(key)
    if key == "escape" then
        states:pop()
    elseif key == "f10" then
        states:push("debug map")
    elseif key == "w" then
        camera:moveBy(0, mapstep)
    elseif key == "s" then
        camera:moveBy(0, -mapstep)
    elseif key == "a" then
        camera:moveBy(mapstep, 0)
    elseif key == "d" then
        camera:moveBy(-mapstep, 0)
    elseif key == "left" then
        player.mapX = player.mapX - 1
    elseif key == "right" then
        player.mapX = player.mapX + 1
    end
end

function module:update(dt)
    
    player:update(dt)
    camera:center(player.screenX, player.screenY)
    camera:update(dt)

end

function module:draw()
    
    -- must render the map outside any transformations
    maprender:render()

    camera:pose()

    love.graphics.setColor(255, 255, 255)
    --love.graphics.scale(2, 2)
    love.graphics.draw(maprender.image)
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", player.screenX + 8, player.screenY, 8)

    camera:relax()
    
    -- debug camera window
    love.graphics.rectangle("line", camera.left, camera.top, camera.width, camera.height)

end

return module
