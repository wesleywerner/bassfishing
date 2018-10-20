--[[
   bass fishing
   top-lunkers.lua

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

function module:init(newLunkers)

    -- save the list of new lunkers
    self.newLunkers = newLunkers or { }

    -- save screen and use it as a menu background
    love.graphics.captureScreenshot (function(data) self.screenshot = love.graphics.newImage (data) end)

    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

    -- measure font size
    self.fontHeight = love.graphics.newText(game.fonts.small, "BASS"):getHeight()

    -- column postitions
    self.columns = {
        20,     -- rank
        60,     -- date
        170,    -- weight
        280,    -- name
        510,    -- lake
    }

    self:prerender()

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
        -- release screenshot
        self.screenshot = nil
        -- exit this state
        game.states:pop()
    end

end

function module:draw()

    -- skip drawing after screenshot is cleared
    if not self.screenshot then return end

    -- underlay screenshot
    local fade = 255 - (128 * self.transition.scale)
    love.graphics.setColor(fade, fade, fade)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("drop down")

    -- background
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(game.border)

    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.image, 0, 0)

end

function module:prerender()

    -- prerender the list to canvas
    self.image = love.graphics.newCanvas(game.window.width, game.window.height)
    love.graphics.setCanvas(self.image)

    -- font color
    love.graphics.setColor(game.color.base0)

    -- title
    love.graphics.setFont(game.fonts.large)
    love.graphics.printf("top lunkers", 0, 20, game.window.width, "center")
    love.graphics.setFont(game.fonts.medium)
    love.graphics.printf("of all time", 0, 80, game.window.width, "center")

    -- records
    love.graphics.setFont(game.fonts.small)

    -- print at offset
    love.graphics.translate(20, 120)

    for n, record in ipairs(game.logic.toplunkers.data.lunkers) do

        local py = n * self.fontHeight

        -- hilite new lunkers
        local hilite = false
        for _, new in ipairs(self.newLunkers) do
            if record == new then
                hilite = true
            end
        end

        if hilite then
            love.graphics.setColor(game.color.magenta)
        else
            love.graphics.setColor(game.color.base0)
        end

        love.graphics.print(n, self.columns[1], py)
        love.graphics.print(os.date("%x", record.date), self.columns[2], py)
        love.graphics.print(game.lib.convert:weight(record.weight), self.columns[3], py)
        love.graphics.print(record.name, self.columns[4], py)
        love.graphics.printf(record.lake, self.columns[5], py,
            game.window.width - self.columns[5] - 60, "right")

    end

    -- top lunker entry notice
    if #self.newLunkers > 0 then

        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(game.color.magenta)

        love.graphics.printf(
            "Your catch made it into the top lunker records! With great decorum the officials add your name to the wall.",
            60, 300, game.window.width - 120, "center")

    end

    love.graphics.setCanvas()

end

return module
