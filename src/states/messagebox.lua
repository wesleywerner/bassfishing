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

    -- expect data to contain "title", "message" and optionally "shake" bool.

    -- save screen and use it as a menu background
    love.graphics.captureScreenshot (function(data) self.screenshot = love.graphics.newImage (data) end)

    -- reset transforms
    love.graphics.origin()

    self.timepassed = 0
    self.fade = 0

    -- this is a YN prompt message
    self.prompt = data.prompt
    self.callback = data.callback
    self.shake = data.shake

    -- pause the outboard sound while the message is showing
    game.sound:stop("outboard")

    -- sound effects
    if self.prompt then
        game.sound:play("prompt")
    elseif self.shake then
        game.sound:play("crash")
    end

    -- predraw the messages on a canvas
    self.canvas = love.graphics.newCanvas( )
    love.graphics.setCanvas( self.canvas )

    local frameLeft = game.window.width * 0.1
    local frameTop = game.window.height * 0.2
    local frameWidth = game.window.width * 0.8
    local frameHeight = game.window.height * 0.4

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

    -- screen transition
    self.transition = game.view.screentransition:new(game.transition.time / 2, game.transition.enter)

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

    self.transition:update(math.min(0.02, dt))

    -- when opening animation completes, fade the message into view
    if self.transition.isOpen then
        self.fade = math.min(255, self.fade + 10)
        self.timepassed = self.timepassed + dt
    end

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

    -- shake effect
    love.graphics.push()

    if self.shake then
        if not self.transition.closing then

            -- shake for opening
            self.transition:apply("shake")

            -- underlay screenshot after applying effect (this shakes everything)
            love.graphics.setColor(game.color.white)
            love.graphics.draw(self.screenshot)

        else

            -- underlay screenshot before applying effect
            love.graphics.setColor(game.color.white)
            love.graphics.draw(self.screenshot)

            -- zoom for closing
            self.transition:apply("zoom")

        end

        -- fade the message into view (only after opening animation is done)
        love.graphics.setColor(255, 255, 255, self.fade)

    else

        -- underlay screenshot
        love.graphics.setColor(game.color.white)
        love.graphics.draw(self.screenshot)

        -- zoom for non-shaking messages
        self.transition:apply("zoom")

        -- draw message without any fade
        love.graphics.setColor(game.color.white)

    end

    love.graphics.draw(self.canvas)

    love.graphics.pop()

end

return module
