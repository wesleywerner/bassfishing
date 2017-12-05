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
local glob = require("logic.globals")
local genie = require("logic.lakegenerator")
local states = require("logic.states")
local camera = require("libs.camera")
local maprender = require("views.maprender")
local fishfinder = require("views.fishfinder")
--local messages = require("messages")
local tiles = require("views.tiles")
local boat = require("logic.boat")
local player = require("logic.player")
local playerView = require("views.player")
local competitors = require("logic.competitors")
local competitorsView = require("views.competitors")
local fishAI = require("logic.fish")
local fishView = require("views.fish")
local weather = require("logic.weather")
local weatherdisplay = require("views.weather-display")
local livewell = require("logic.livewell")
local livewellView = require("views.livewell")

local scale = 2
local drawDebug = false


function module:init()

    self.windowWidth = love.graphics.getWidth( )
    self.windowHeight = love.graphics.getHeight( )

    -- TODO: move to a state.
    if not glob.lake then

        glob.lake = genie:generate(glob.defaultMapWidth,
        glob.defaultMapHeight, glob.defaultMapSeed,
        glob.defaultMapDensity, glob.defaultMapIterations)

        -- prepare the player boat
        boat:prepare(player)
        boat:launchBoat(player)
        -- add player boat to the boats list so it can be included in obstacle tests
        table.insert(glob.lake.boats, player)

        camera:worldSize(glob.lake.width * tiles.size * scale,
        glob.lake.height * tiles.size * scale)

        camera:frame(10, 10,
            love.graphics.getWidth( ) - 200,
            love.graphics.getHeight( ) - 42)

    end

    -- load the game border
    if not self.borderImage then
        self.borderImage = love.graphics.newImage("res/game-border.png")
    end

    -- set up our fish finder
    fishfinder:update()

    -- change the weather (TODO: should move to a next day state)
    weather:change()
    print("\nThe weather changed")
    print(string.format("approachingfront\t: %s", tostring(weather.approachingfront) ))
    print(string.format("postfrontal\t\t: %s", tostring(weather.postfrontal) ))
    print(string.format("airTemperature\t\t: %d", weather.airTemperature ))
    print(string.format("waterTemperature\t: %d", weather.waterTemperature ))
    print(string.format("cloudcover\t\t: %f", weather.cloudcover ))
    print(string.format("windSpeed\t\t: %d", weather.windSpeed ))
    print(string.format("rain\t\t\t: %s", tostring(weather.rain) ))

    love.graphics.setFont( glob.fonts.small )

end

function module:keypressed(key)
    if key == "escape" then
        states:pop()
    elseif key == "f10" then
        states:push("lakegen development")
    elseif key == "left" or key == "kp4" or key == "a" then
        fishAI:move()
        competitors:move()
        player:left()
        fishfinder:update()
    elseif key == "right" or key == "kp6" or key == "d" then
        fishAI:move()
        competitors:move()
        player:right()
        fishfinder:update()
    elseif key == "up" or key == "kp8" or key == "w" then
        fishAI:move()
        competitors:move()
        player:forward()
        fishfinder:update()
    elseif key == "down" or key == "kp2" or key == "s" then
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

    -- test if the point is inside the camera frame
    x, y = camera:pointToFrame(x, y)

    if x and y then
        -- update turns TODO: move to a turn function?
        fishAI:move()
        competitors:move()
        fishfinder:update()
        player:cast()
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

    -- draw game border
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.borderImage)

    camera:pose()

    -- draw the map
    love.graphics.setColor(255, 255, 255)
    love.graphics.scale(scale, scale)
    love.graphics.draw(maprender.image)

    -- fish (debugging)
    if drawDebug then fishView:draw() end

    -- draw other boats
    competitorsView:draw()

    -- draw player boat
    playerView:drawBoat()

    camera:relax()

    -- fish finder
    love.graphics.push()
    love.graphics.translate(628, 434)
    fishfinder:draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(612, 10)
    weatherdisplay:draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(10, 570)
    playerView:drawRodDetails()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(620, 188)
    livewellView:draw()
    love.graphics.pop()

end

return module