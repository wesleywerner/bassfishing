--[[
   array2d.lua

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

-- time to wait before allowing dialog close
local closeAfterTime = .6

function module:init(data)

    -- expect data to contain "title", "message" and optionally "shake bool".

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    -- reset transforms
    love.graphics.origin()

    self.timepassed = 0
    self.fade = 0
    self.shaking = data.shake and 60 or 0

    -- this is a YN prompt message
    self.prompt = data.prompt
    self.callback = data.callback

    -- predraw the messages on a canvas
    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()
    self.canvas = love.graphics.newCanvas( )
    love.graphics.setCanvas( self.canvas )

    local frameLeft = self.width * 0.1
    local frameTop = self.height * 0.2
    local frameWidth = self.width * 0.8
    local frameHeight = self.height * 0.4

    -- draw a frame
    love.graphics.setColor(0, 0, 0, 164)
    love.graphics.rectangle("fill", frameLeft, frameTop, frameWidth, frameHeight )
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", frameLeft, frameTop, frameWidth, frameHeight )

    -- print title
    if data.title then
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(game.fonts.large)
        love.graphics.printf(data.title, frameLeft, frameTop + 30, frameWidth, "center")
    end

    -- print message
    local border = 20
    if data.message then
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(game.fonts.medium)
        love.graphics.printf(data.message, frameLeft + border, frameTop + 110, frameWidth - border - border, "center")
    end

    love.graphics.setCanvas()

end

function module:keypressed(key)

    if self.prompt and key == "Y" or key == "y" then
        if type(self.callback) == "function" then
            game.states:pop()
            self.callback()
        end
    elseif self.timepassed > closeAfterTime then
        game.states:pop()
    end

end

function module:mousepressed( x, y, button, istouch )

    if self.timepassed > closeAfterTime then
        game.states:pop()
    end

end

function module:update(dt)

    if self.shaking < 1 then
        self.fade = math.min(255, self.fade + 10)
        self.timepassed = self.timepassed + dt
    end

    self.shaking = game.lib.lume.lerp(self.shaking, 0, 7*dt)

end

function module:draw()

    -- shake effect
    love.graphics.push()
    if self.shaking > 1 then
        love.graphics.translate((math.random()-.5) * self.shaking, (math.random()-.5) * self.shaking)
    end

    -- underlay screenshot
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.screenshot)

    love.graphics.setColor(255, 255, 255, self.fade)
    love.graphics.draw(self.canvas)

    love.graphics.pop()

end

return module
