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
    if key == "escape" then
        self.transition:close(1, "inBack")
    end
end

function module:mousemoved( x, y, dx, dy, istouch )

end

function module:mousepressed( x, y, button, istouch )

    self.transition:close(1, "inBack")

end

function module:update(dt)

    self.transition:update(dt)

    if self.transition.complete and self.transition.closing then
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
    love.graphics.translate(0, self.height - (self.height * self.transition.scale))

    -------------------------------

    local frameLeft = 0
    local frameTop = 0
    local frameWidth = self.width
    local frameHeight = self.height

    -- draw a frame
    love.graphics.setColor(game.color.base2)
    love.graphics.rectangle("fill", frameLeft, frameTop, frameWidth, frameHeight )
    love.graphics.setColor(game.color.base3)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", frameLeft, frameTop, frameWidth, frameHeight )

    -- print title
    love.graphics.setColor(game.color.base01)
    love.graphics.setFont(game.fonts.large)
    love.graphics.printf("weigh in", frameLeft, frameTop + 30, frameWidth, "center")


    -------------------------------

    -- restore state
    love.graphics.pop()

end

return module
