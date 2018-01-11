--[[
   bass fishing
   weigh-in.lua

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

-- alias tournament logic
local tour = nil

function module:init(data)

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

    if not game.logic.player.nearJetty then
        game.dprint("The player missed the weigh-in!")
    end

    tour = game.logic.tournament

    -- sort the daily weight list
    table.sort(tour.standings, function(a, b) return a.dailyWeight > b.dailyWeight end)

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

    -- limit delta as the end of day weigh-in can use up to .25 seconds
    -- causing a transition jump.
    self.transition:update(math.min(0.02, dt))

    if self.transition.isClosed then
        -- release screenshot
        self.screenshot = nil
        -- forward the tournament day
        game.logic.tournament:nextDay()
        -- exit this state
        game.states:pop()
    end

end

function module:draw()

    -- underlay screenshot
    local fade = 255 - (128 * self.transition.scale)
    love.graphics.setColor(fade, fade, fade)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("drop down")

    -- background
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(game.border)

    -- print title
    love.graphics.setColor(game.color.base01)
    love.graphics.setFont(game.fonts.large)
    love.graphics.printf(string.format("weigh in day %d", game.logic.tournament.day),
        0, 30, game.window.width, "center")

    love.graphics.setFont(game.fonts.medium)

    -- the player missed the weigh-in
    if not game.logic.player.nearJetty then
        love.graphics.setColor(game.color.red)
        love.graphics.printf("You missed the weigh-in!", 0, 90, game.window.width, "center")
    end

    love.graphics.setFont(game.fonts.small)

    -- list standings
    local position = 1
    for i, angler in ipairs(tour.standings) do

        if (i <= 10) or (i > 10 and angler.player) then

            position = position + 1
            local py = 60 + (position * 30)

            if angler.player then
                love.graphics.setColor(game.color.green)
            else
                love.graphics.setColor(game.color.base01)
            end

            -- name
            love.graphics.print(string.format("%d. %s", i, angler.name), 100, py)

            -- weight
            love.graphics.printf(game.lib.convert:weight(angler.dailyWeight),
            0, py, game.window.width - 60, "right")

        end

    end

    -- lunker of the day
    love.graphics.setColor(game.color.violet)
    love.graphics.printf(
        string.format("The lunker of the day goes to:\n%s with a catch of %s!",
        tour.lunkerOfTheDay.name, game.lib.convert:weight(tour.lunkerOfTheDay.weight)),
        0, game.window.height - 140, game.window.width, "center")

    -- print last day message
    if game.logic.tournament.day == 3 then

        love.graphics.setColor(game.color.red)
        love.graphics.printf("Tournament standings are up next...", 0,
        game.window.height - 40, game.window.width, "center")

    end

end

return module
