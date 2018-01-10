--[[
   map.lua

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

function module:init()

    -- pre-calculate centering lake on screen
    self.mapscale = 9
    self.lakeCenter = (game.window.width / module.mapscale / 2) - (game.defaultMapWidth / 2)
    self.lakeBottom = (game.window.height / module.mapscale / 2) - (game.defaultMapHeight / 2)

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    -- render the map
    self.mapimage = game.view.maprender:renderMini(true)

    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

    self.flasher = 0

end


function module:keypressed(key)

    self.transition:close(game.transition.time, game.transition.exit)

end

function module:mousepressed( x, y, button, istouch )

    self.transition:close(game.transition.time, game.transition.exit)

end

function module:update(dt)

    self.flasher = self.flasher + dt

    self.transition:update(dt)

    if self.transition.isClosed then
        -- release screenshot
        self.screenshot = nil
        -- exit this state
        game.states:pop()
    end

end

function module:draw()

    -- underlay screenshot
    local fade = 255 - (128 * self.transition.scale)
    love.graphics.setColor(fade, fade, fade)
    love.graphics.draw(self.screenshot)

    self.transition:apply("zoom")

    -- scale the mini map to fit the screen
    love.graphics.push()
    love.graphics.scale(self.mapscale, self.mapscale)
    love.graphics.translate(self.lakeCenter, self.lakeBottom)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.mapimage, 0, 0)

    -- flash the player position
    if math.floor(self.flasher) % 2 == 0 then
        -- compensate drawing one-based coordinates on a zero-based canvas
        love.graphics.push()
        love.graphics.translate(-1, -1)
        love.graphics.setColor(game.color.base1)
        love.graphics.rectangle("fill", game.logic.player.x, game.logic.player.y, 1, 1)
        love.graphics.pop()
    end

    -- restore state
    love.graphics.pop()

end

return module
