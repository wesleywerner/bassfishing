--[[
   bass fishing
   module.lua

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

--- Provides a text input state.
-- @module text-entry

local module = { }

--- Initialize the text entry state.
--
-- @tparam init_data data
function module:init(data)

    --- state initialization data
    --
    -- @table init_data
    --
    -- @tfield function callback
    -- The callback function when input is accepted.
    -- Receives the input text as first parameter.
    --
    -- @tfield[opt] string title
    -- The title to display on the text entry.
    --
    -- @tfield[opt] string text
    -- The default text for the input operation.

    -- expect data to contain a callback on successful input
    self.callback = data.callback
    self.title = data.title
    self.text = data.text or ""
    self.alphabet = "abcdefghijklmnopqrstuvwxyz"

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()
    self.frameLeft = self.width * 0.1
    self.frameTop = self.height * 0.2
    self.frameWidth = self.width * 0.8
    self.frameHeight = self.height * 0.4
    self.textLeft = self.frameLeft + 100
    self.textTop = self.frameTop + 100
    self.titleLeft = self.frameLeft + 40
    self.titleTop = self.frameTop + 40

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    self.transition = game.view.screentransition:new(game.transition.time / 2, game.transition.enter)

    love.graphics.setFont(game.fonts.medium)

    -- enable key repeat so backspace can be held down to trigger love.keypressed multiple times
    love.keyboard.setKeyRepeat(true)

end

function module:keypressed(key)

    if key == "escape" then
        self.transition:close(game.transition.time / 2, game.transition.exit)
    elseif key == "return" then
        if type(self.callback) == "function" then
            self.callback(self.text)
        end
        self.transition:close(game.transition.time / 2, game.transition.exit)
    elseif key == "backspace" then

        local utf8 = require("utf8")

        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(self.text, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters,
            -- so we couldn't do string.sub(text, 1, -2).
            self.text = string.sub(self.text, 1, byteoffset - 1)
        end
    elseif self.alphabet:find(key) and self.text:len() < 24 then
        self.text = self.text..key
    elseif key == "space" and self.text:len() < 24 then
        self.text = self.text.." "
    end

end

function module:mousemoved( x, y, dx, dy, istouch )

end

function module:mousepressed( x, y, button, istouch )

end

function module:update(dt)

    self.transition:update(dt)

    if self.transition.isClosed then
        -- disable key repeat
        love.keyboard.setKeyRepeat(false)
        game.states:pop()
    end

end

function module:draw()

    -- save state
    love.graphics.push()

    -- underlay screenshot
    love.graphics.setColor(128, 128, 128)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("center zoom")

    -- draw a frame
    love.graphics.setColor(game.color.base2)
    love.graphics.rectangle("fill", self.frameLeft, self.frameTop,
        self.frameWidth, self.frameHeight)

    -- print title
    if self.title then
        love.graphics.setColor(game.color.base01)
        love.graphics.print(self.title, self.titleLeft, self.titleTop)
    end

    -- print text
    love.graphics.setColor(game.color.base01)
    love.graphics.print(self.text .. "_", self.textLeft, self.textTop)

    -- restore state
    love.graphics.pop()

end

return module
