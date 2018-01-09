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

local module = { }

function module:init(data)

    -- expect data to contain "title", "message" and optionally "shake bool".

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    -- load background image
    if not self.background then
        self.background = love.graphics.newImage("res/tackle-rods.png")
        self.backgroundY = self.height - self.background:getHeight()
        self.exitAbove = self.backgroundY
        self.tackleTop = self.backgroundY + 60
    end

    self.transition = game.view.screentransition:new(0.5, "inCubic")

    -- font to draw the rod list
    self.listFont = game.fonts.small

    -- selection padding
    local padding = 20

    -- spacing between printed rows
    self.linespacing = 30

    -- height of font, used to center text
    local fontHeight = math.floor(love.graphics.newText(self.listFont, "ABC"):getHeight() / 2)

    -- define clickable hotspots
    self.hotspots = { }

    local n = 1
    for i, rod in ipairs(game.logic.tackle.rods) do

        local rodrange = game.lib.convert:distance(rod.range * game.view.tiles.inmeters)

        table.insert(self.hotspots,
            game.lib.hotspot:new{
                top = self.tackleTop + (self.linespacing * n),
                left = padding,
                width = self.width - padding * 2,
                height = self.linespacing,
                rod = rod,
                textY = (self.linespacing / 2) - fontHeight,
                text = string.format("%s, range %s", rod.name, rodrange),
                }
        )

        n = n + 1

    end

    -- the current player rod
    self.playerRod = game.logic.player.rod and game.logic.player.rod.name or nil

end

function module:keypressed(key)

    if key == "escape" then

        self.transition:close(0.5, "outBack")

    end

end

function module:mousemoved( x, y, dx, dy, istouch )

    -- focus hotspots
    for _, hotspot in ipairs(self.hotspots) do
        hotspot:mousemoved(x, y, dx, dy, istouch)
    end

end

function module:mousepressed( x, y, button, istouch )

    if y < self.exitAbove then

        self.transition:close(0.5, "outBack")

    end

    -- focus hotspots
    for _, hotspot in ipairs(self.hotspots) do
        hotspot:mousemoved(x, y, dx, dy, istouch)

        if hotspot.focused then

            -- set the player cast range and rod name
            game.logic.player:setRod(hotspot.rod)

            -- close the rod selection
            self.transition:close(0.5, "outBack")

        end

    end

end

function module:update(dt)

    self.transition:update(dt)

    -- exit this state when the transition is closed
    if self.transition.isClosed then

        -- remove this state
        game.states:pop()

        -- if the rod has no lure, show lure selection as a courtesy
        if game.logic.player.rod and not game.logic.player.rod.lure then
            game.states:push("tackle lures", self.screenshot)
        end

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
    self.transition:apply("slide up", self.backgroundY)

    -- tackle background
    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.background, 0, self.backgroundY)

    -- list rods
    love.graphics.setFont(self.listFont)

    for _, hotspot in ipairs(self.hotspots) do

        if hotspot.rod.name == self.playerRod or hotspot.focused then
            -- selected focus
            love.graphics.setColor(game.color.blue)
            love.graphics.rectangle("fill", hotspot.left, hotspot.top,
                hotspot.width, hotspot.height)
            love.graphics.setColor(game.color.base3)
        else
            -- normal
            love.graphics.setColor(game.color.base01)
        end

        -- print rod name
        love.graphics.print(hotspot.text, hotspot.left + 20, hotspot.top + hotspot.textY)

        -- print rod lure
        if hotspot.rod.lure then
            love.graphics.printf(string.format("%s %s", hotspot.rod.lure.color, hotspot.rod.lure.name),
                hotspot.left, hotspot.top + hotspot.textY, hotspot.width, "right")
        end

    end

    -- restore state
    love.graphics.pop()

end

return module
