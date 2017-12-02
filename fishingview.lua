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
local camera = require("camera")
local maprender = require("maprender")
local fishfinder = require("fishfinder")
--local messages = require("messages")
local tiles = require("tiles")
local boat = require("boat")
local player = require("player")
local boatAI = require("boat-ai")
local fishAI = require("fish-ai")
local scale = 2
local drawDebug = false


function module:init()

    self.windowWidth = love.graphics.getWidth( )
    self.windowHeight = love.graphics.getHeight( )

    -- create a new map on the global module.
    if not glob.lake then
        glob.lake = genie:generate(glob.defaultMapWidth,
        glob.defaultMapHeight, glob.defaultMapSeed,
        glob.defaultMapDensity, glob.defaultMapIterations)

        -- prepare the player boat
        boat:prepare(player)
        boat:launchBoat(player)
        -- add player boat to the boats list so it can be included in obstacle tests
        table.insert(glob.lake.boats, player)

        camera:worldSize(glob.lake.width * tiles.size * scale, glob.lake.height * tiles.size * scale)
        camera:frame(10, 10, love.graphics.getWidth( ) - 200, love.graphics.getHeight( ) - 20)
    end

    -- set up our fish finder
    fishfinder:update()

    love.graphics.setFont( love.graphics.newFont( 20 ) )

end

function module:keypressed(key)
    if key == "escape" then
        states:pop()
    elseif key == "f10" then
        states:push("debug map")
    elseif key == "left" or key == "kp4" then
        fishAI:move()
        boatAI:move()
        player:left()
        fishfinder:update()
    elseif key == "right" or key == "kp6" then
        fishAI:move()
        boatAI:move()
        player:right()
        fishfinder:update()
    elseif key == "up" or key == "kp8" then
        fishAI:move()
        boatAI:move()
        player:forward()
        fishfinder:update()
    elseif key == "down" or key == "kp2" then
        fishAI:move()
        boatAI:move()
        player:reverse()
        fishfinder:update()
    elseif key == "tab" then
        drawDebug = not drawDebug
    end
end

function module:update(dt)

    boatAI:update(dt)
    player:update(dt)
    if drawDebug then fishAI:update(dt) end

    camera:center(player.screenX * scale, player.screenY * scale)
    camera:update(dt)

end

function module:draw()

    -- must render the map outside any transformations
    maprender:render()

    camera:pose()

    -- draw the map
    love.graphics.setColor(255, 255, 255)
    love.graphics.scale(scale, scale)
    love.graphics.draw(maprender.image)

    -- fish (debugging)
    if drawDebug then
        for _, fish in ipairs(glob.lake.fish) do
            love.graphics.setColor(0, 128, 255, 64)
            if fish.feeding then
                love.graphics.draw(tiles.image, tiles.fish.feed, fish.screenX, fish.screenY)
            else
                love.graphics.draw(tiles.image, tiles.fish.home, fish.screenX, fish.screenY)
            end
        end
    end

    -- draw other boats
    for _, craft in ipairs(glob.lake.boats) do
        love.graphics.setColor(craft.color)
        love.graphics.draw(tiles.image, tiles.boats[3], craft.screenX + 8,
        craft.screenY + 8, math.rad(craft.angle), 1, 1, 8, 8 )

        if drawDebug and craft.stuck then
            love.graphics.rectangle("line", craft.screenX, craft.screenY, 16, 16)
        end

    end

    -- draw player boat
    love.graphics.setColor(0, 255, 255)
    love.graphics.draw(tiles.image, tiles.boats[3], player.screenX + 8,
    player.screenY + 8, math.rad(player.angle), 1, 1, 8, 8 )

    camera:relax()

    -- camera window
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", camera.frameLeft, camera.frameTop, camera.frameWidth, camera.frameHeight)

    -- fish finder
    love.graphics.push()
    love.graphics.translate(self.windowWidth - 170, 20)
    love.graphics.setColor(255, 255, 255)
    fishfinder:draw()
    love.graphics.pop()


    love.graphics.print(string.format("boat speed: %d", player.speed))

end

return module
