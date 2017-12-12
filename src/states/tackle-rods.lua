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
        self.tackleTop = self.backgroundY + 20
    end

    self.transition = game.view.screentransition:new(1, "outCubic")

    -- define clickable hotspots
    if not self.hotspots then

        self.hotspots = { }

        local n = 1
        for i, rod in ipairs(game.logic.tackle.rods) do

            table.insert(self.hotspots,
                game.lib.hotspot:new{
                    top=self.tackleTop + (40 * n),
                    left=50,
                    width=self.width,
                    height=40,
                    rod=rod,
                    }
            )

            n = n + 1

        end

    end

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

        if hotspot.touched then

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
            game.states:push("tackle lures")
        end

    end

end

function module:draw()


    -- save state
    love.graphics.push()

    -- underlay screenshot
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(self.screenshot)

    -- apply transform
    love.graphics.translate(0, self.backgroundY - (self.backgroundY * self.transition.scale))

    -- tackle background
    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.background, 0, self.backgroundY)

    -- list rods
    love.graphics.setFont(game.fonts.small)

    for _, hotspot in ipairs(self.hotspots) do

        if hotspot.touched then
            love.graphics.setColor(game.color.magenta)
        else
            love.graphics.setColor(game.color.base01)
        end

        love.graphics.print(hotspot.rod.name, hotspot.left, hotspot.top)

    end

    -- restore state
    love.graphics.pop()

end

return module
