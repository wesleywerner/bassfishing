--[[
   livewell.lua

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

function module:draw()

    -- width used to right-align printed text
    local w, h = 160, 150

    love.graphics.setFont(game.fonts.medium)

    -- offset the text
    love.graphics.push()
    love.graphics.translate(0, 10)

    for i, fish in ipairs(game.logic.livewell.contents) do

        love.graphics.setColor(game.color.base1)
        local py = (i - 1) * 24
        love.graphics.draw(game.view.tiles.image, game.view.tiles.fish[fish.size], 0, py)
        love.graphics.printf(game.lib.convert:weight(fish.weight), 0, py, w, "right")

        -- hilite a fish in the live well
        if fish.hilite then
            local g = game.color.green
            love.graphics.setColor(g[1], g[2], g[3], 255 * fish.hilite)
            fish.hilite = (fish.hilite > 0) and (fish.hilite - 0.002) or nil
            love.graphics.draw(game.view.tiles.image, game.view.tiles.fish[fish.size], 0, py)
        end

    end

    love.graphics.pop()

end

return module
