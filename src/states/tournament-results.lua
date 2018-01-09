--[[
   bass fishing
   tournament-results.lua

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

function module:init(data)

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

end

function module:keypressed(key)

    self.transition:close(game.transition.time, game.transition.exit)

end

function module:mousemoved( x, y, dx, dy, istouch )

end

function module:mousepressed( x, y, button, istouch )

    self.transition:close(game.transition.time, game.transition.exit)

end

function module:update(dt)

    self.transition:update(dt)

    if self.transition.isClosed then
        game.states:pop()
    end

end

function module:draw()


    -- save state
    love.graphics.push()

    -- underlay screenshot
    local fade = 255 - (128 * self.transition.scale)
    love.graphics.setColor(fade, fade, fade)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("drop down")

    -- background
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(game.border)

    local frameLeft = 0
    local frameTop = 0
    local frameWidth = game.window.width
    local frameHeight = game.window.height

    -- print title
    love.graphics.setColor(game.color.base01)
    love.graphics.setFont(game.fonts.large)
    love.graphics.printf("Tournament Results", frameLeft, frameTop + 30, frameWidth, "center")

    -- list standings by total weight
    local position = 1
    love.graphics.setFont(game.fonts.small)
    for i, angler in ipairs(game.logic.tournament.standings) do

        if (i <= 10) or (i > 10 and angler.player) then

            position = position + 1
            local py = 100 + (position * 30)

            if angler.player then
                love.graphics.setColor(game.color.green)
            else
                love.graphics.setColor(game.color.base01)
            end

            -- name
            love.graphics.print(string.format("%d. %s", i, angler.name), 100, py)

            -- weight
            love.graphics.printf(game.lib.convert:weight(angler.totalWeight),
            0, py, game.window.width - 60, "right")

        end

    end

    -- restore state
    love.graphics.pop()

end

return module
