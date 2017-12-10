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

function module:init(data)

    -- expect data to contain "title", "message" and optionally "shake bool".

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    self.transition = game.view.screentransition:new(3, "outBounce")

end

function module:keypressed(key)

    self.transition:close(1, "inBack")

end

function module:mousemoved( x, y, dx, dy, istouch )

end

function module:mousepressed( x, y, button, istouch )

    self.transition:close(1, "inBack")

end

function module:update(dt)

    self.transition:update(dt)

    if self.transition.isClosed then
        game.logic.tournament:nextDay()
        game.states:pop()
    end

end

function module:draw()

    -- save state
    love.graphics.push()

    -- underlay screenshot
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.screenshot)

    -- apply transform
    love.graphics.translate(0, - self.height + (self.height * self.transition.scale))

    local tour = game.logic.tournament
    local frameLeft = 0
    local frameTop = 0
    local frameWidth = self.width
    local frameHeight = self.height

    -- draw a frame
    love.graphics.setColor(game.color.base2)
    love.graphics.rectangle("fill", frameLeft, frameTop, frameWidth, frameHeight )

    -- border
    love.graphics.setColor(game.color.base03)

    -- TODO: this adds a nice fat border but seems to affect the minimap on lake selection
    --love.graphics.setLineWidth(40)
    love.graphics.rectangle("line", frameLeft, frameTop, frameWidth, frameHeight )

    -- print title
    love.graphics.setColor(game.color.base01)
    love.graphics.setFont(game.fonts.large)
    love.graphics.printf(string.format("weigh in day %d", game.logic.tournament.day),
        frameLeft, frameTop + 30, frameWidth, "center")

    love.graphics.setFont(game.fonts.medium)

    -- the player missed the weigh-in
    if not game.logic.player.nearJetty then
        love.graphics.setColor(game.color.red)
        love.graphics.printf("You missed the weigh-in!", 0, 90, self.width, "center")
    end

    love.graphics.setFont(game.fonts.small)

    -- list standings
    for i, angler in ipairs(tour.standings) do

        if i < 11 then

            local py = 100 + (i*30)

            if angler.player then
                love.graphics.setColor(game.color.green)
            else
                love.graphics.setColor(game.color.base01)
            end

            -- name
            love.graphics.print(string.format("%d. %s", i, angler.name), 100, py)

            -- weight
            love.graphics.printf(string.format("%.2f kg", angler.dailyWeight), 0, py, self.width - 20, "right")

        end

    end

    -- lunker of the day
    love.graphics.setColor(game.color.violet)
    love.graphics.printf(
        string.format("The lunker of the day goes to:\n%s with a catch of %.2f kg!",
        tour.lunkerOfTheDay.name, tour.lunkerOfTheDay.weight),
        0, self.height - 160, self.width, "center")

    -- print last day message
    if game.logic.tournament.day == 3 then

        love.graphics.setColor(game.color.red)
        love.graphics.printf("Tournament standings are up next...", 0, self.height - 40, self.width, "center")

    end

    -- restore state
    love.graphics.pop()

end

return module
