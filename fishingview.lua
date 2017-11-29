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
local tiles = require("tiles")
local scale = 2

function module:init()

    -- create a new map on the global module.
    if not glob.lake then
        glob.lake = genie:generate(glob.defaultMapWidth,
        glob.defaultMapHeight, glob.defaultMapSeed,
        glob.defaultMapDensity, glob.defaultMapIterations)
    
        player:launchBoat()
        
        camera:worldSize(glob.lake.width * tiles.size * scale, glob.lake.height * tiles.size * scale)
        camera:frame(10, 10, love.graphics.getWidth( ) - 200, love.graphics.getHeight( ) - 20)
    end

end

function module:keypressed(key)
    if key == "escape" then
        states:pop()
    elseif key == "f10" then
        states:push("debug map")
    elseif key == "left" or key == "kp4" then
        player.mapX = player.mapX - 1
    elseif key == "right" or key == "kp6" then
        player.mapX = player.mapX + 1
    elseif key == "up" or key == "kp8" then
        player.mapY = player.mapY - 1
    elseif key == "down" or key == "kp2" then
        player.mapY = player.mapY + 1
    elseif key == "kp7" then
        player.mapX = player.mapX - 1
        player.mapY = player.mapY - 1
    elseif key == "kp9" then
        player.mapX = player.mapX + 1
        player.mapY = player.mapY - 1
    elseif key == "kp1" then
        player.mapX = player.mapX - 1
        player.mapY = player.mapY + 1
    elseif key == "kp3" then
        player.mapX = player.mapX + 1
        player.mapY = player.mapY + 1
    end
end

function module:update(dt)
    
    player:update(dt)
    camera:center(player.screenX * scale, player.screenY * scale)
    camera:update(dt)

end

function module:draw()
    
    -- must render the map outside any transformations
    maprender:render()

    camera:pose()

    love.graphics.setColor(255, 255, 255)
    love.graphics.scale(scale, scale)
    love.graphics.draw(maprender.image)
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", player.screenX + 8, player.screenY, 8)

    camera:relax()
    
    -- debug camera window
    love.graphics.rectangle("line", camera.frameLeft, camera.frameTop, camera.frameWidth, camera.frameHeight)

end

return module
