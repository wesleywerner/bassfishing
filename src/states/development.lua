--[[
   development.lua

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

local module = { }
local scale = 2
local drawDebug = false

function module:init()

    -- prepare the lake
    game.logic.genie:populateLakeWithFishAndBoats(game.lake)
    game.logic.boat:prepare(game.logic.player)
    game.logic.boat:launchBoat(game.logic.player)

    -- add player boat to the boats list so it can be included in obstacle tests
    table.insert(game.lake.boats, game.logic.player)

    -- load the camera
    game.lib.camera:worldSize(
        game.lake.width * game.view.tiles.size * scale,
        game.lake.height * game.view.tiles.size * scale)

    -- set camera lens size
    game.lib.camera:frame(10, 10,
        love.graphics.getWidth( ) - 200,
        love.graphics.getHeight( ) - 42)

    -- center the camera
    game.lib.camera:instant(-game.lake.width * game.view.tiles.size / 2, -game.lake.height * game.view.tiles.size / 2)

    -- load the game border
    if not self.borderImage then
        self.borderImage = love.graphics.newImage("res/game-border.png")
    end

    -- set up our fish finder
    game.view.fishfinder:update()

    love.graphics.setFont( game.fonts.small )

    game.logic.tournament:start()

end

function module:keypressed(key)
    if key == "escape" then
        game.states:pop()
    elseif key == "left" or key == "kp4" or key == "a" then
        game.logic.player:left()
        game.view.fishfinder:update()
    elseif key == "right" or key == "kp6" or key == "d" then
        game.logic.player:right()
        game.view.fishfinder:update()
    elseif key == "up" or key == "kp8" or key == "w" then
        game.logic.player:forward()
        game.view.fishfinder:update()
    elseif key == "down" or key == "kp2" or key == "s" then
        game.logic.player:reverse()
        game.view.fishfinder:update()
    elseif key == "r" then
        game.states:push("tackle rods")
    elseif key == "l" then
        game.states:push("tackle lures")
    end

    -- debug shortcuts
    if game.debug then
        if key == "tab" then
            drawDebug = not drawDebug
        elseif key == "f10" then
            game.states:push("lakegen development")
        elseif key == "f9" then
            game.logic.tournament:endOfDay()
        elseif key == "t" then
            game.logic.tournament:takeTime(15)
        end
    end

end

function module:mousemoved( x, y, dx, dy, istouch )
    x, y = game.lib.camera:pointToFrame(x, y)
    if x and y then
        game.logic.player:aimCast( x / scale, y / scale )
    end
end

function module:mousepressed( x, y, button, istouch )

    -- test if the point is inside the camera frame
    x, y = game.lib.camera:pointToFrame(x, y)

    if x and y then
        -- update turns TODO: move to a turn function?
        game.view.fishfinder:update()
        game.logic.player:cast()
    end

end

function module:update(dt)

    game.logic.competitors:update(dt)

    -- check if the day is over
    if game.logic.tournament.time == 0 then
        game.logic.tournament:endOfDay()
    end

    -- if near the jetty and less than 30 minutes remain, end the day
    if game.logic.tournament.displayedWarning
        and game.logic.player.nearJetty
        and game.logic.player.speed == 0 then
        game.logic.tournament:endOfDay()
    end

    game.logic.player:update(dt)

    if drawDebug then game.logic.fish:update(dt) end

    game.lib.camera:center(game.logic.player.screenX * scale, game.logic.player.screenY * scale)
    game.lib.camera:update(dt)

end

function module:draw()

    -- must render the map outside any transformations
    game.view.maprender:render()
    game.view.fishfinder:render()

    -- draw game border
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.borderImage)

    game.lib.camera:pose()

    -- draw the map
    love.graphics.setColor(255, 255, 255)
    love.graphics.scale(scale, scale)
    love.graphics.draw(game.view.maprender.image)

    -- fish (debugging)
    if drawDebug then game.view.fish:draw() end

    -- draw other boats
    game.view.competitors:draw()

    -- draw player boat
    game.view.player:draw()

    game.lib.camera:relax()

    -- fish finder
    love.graphics.push()
    love.graphics.translate(628, 434)
    game.view.fishfinder:draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(620, 14)
    game.view.clock:draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(612, 10)
    game.view.weather:draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(10, 570)
    game.view.player:drawRodDetails()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(620, 188)
    game.view.livewell:draw()
    love.graphics.pop()

end

return module
