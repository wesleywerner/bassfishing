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
local competitors = require("boat-ai")
local fishAI = require("fish-ai")
local weather = require("weather")
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

    -- change the weather (TODO: should move to a next day state)
    weather:change()

    love.graphics.setFont( love.graphics.newFont( 20 ) )

end

function module:keypressed(key)
    if key == "escape" then
        states:pop()
    elseif key == "f10" then
        states:push("debug map")
    elseif key == "left" or key == "kp4" then
        fishAI:move()
        competitors:move()
        player:left()
        fishfinder:update()
    elseif key == "right" or key == "kp6" then
        fishAI:move()
        competitors:move()
        player:right()
        fishfinder:update()
    elseif key == "up" or key == "kp8" then
        fishAI:move()
        competitors:move()
        player:forward()
        fishfinder:update()
    elseif key == "down" or key == "kp2" then
        fishAI:move()
        competitors:move()
        player:reverse()
        fishfinder:update()
    elseif key == "tab" then
        drawDebug = not drawDebug
    end
end

function module:mousemoved( x, y, dx, dy, istouch )
    x, y = camera:pointToFrame(x, y)
    if x and y then
        player:aimCast( x / scale, y / scale )
    end
end

function module:mousepressed( x, y, button, istouch )
    x, y = camera:pointToFrame(x, y)
    if x and y then
        -- update turns TODO: move to a turn function?
        fishAI:move()
        competitors:move()
        fishfinder:update()
        -- TODO: provide lure data to the strike
        local fish = fishAI:attemptStrike(player.castOffset.x, player.castOffset.y)
        if fish then
            player:landFish(fish)
        end
    end
end

function module:update(dt)

    competitors:update(dt)
    player:update(dt)
    if drawDebug then fishAI:update(dt) end

    camera:center(player.screenX * scale, player.screenY * scale)
    camera:update(dt)

end

function module:draw()

    -- must render the map outside any transformations
    maprender:render()
    fishfinder:render()

    camera:pose()

    -- draw the map
    love.graphics.setColor(255, 255, 255)
    love.graphics.scale(scale, scale)
    love.graphics.draw(maprender.image)

    -- fish (debugging)
    if drawDebug then fishAI:draw() end

    -- draw other boats
    competitors:draw()

    -- draw player boat
    player:draw()

    camera:relax()

    -- camera window
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", camera.frameLeft, camera.frameTop, camera.frameWidth, camera.frameHeight)

    -- fish finder
    love.graphics.push()
    love.graphics.translate(self.windowWidth - fishfinder.width * 1, 20)
    fishfinder:draw()
    love.graphics.pop()

    love.graphics.print(string.format("boat speed: %d", player.speed))

end

return module
