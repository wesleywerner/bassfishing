--[[
   minimap.lua

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

-- Render a preview of the lake contour to a canvas
function module:render(showPlayer)

    local preview = love.graphics.newCanvas(game.lake.width, game.lake.height)
    love.graphics.setCanvas(preview)

    -- compensate drawing one-based coordinates on a zero-based canvas
    love.graphics.push()
    love.graphics.translate(-1, -1)

    for x=1, game.lake.width do
        for y=1, game.lake.height do

            local land = game.lake.contour[x][y] > 0

            if land then
                love.graphics.setColor(game.color.base03)
                love.graphics.rectangle("fill", x, y, 1, 1)
            else
                -- draw lake depth
                local depth = game.lake.depth[x][y]
                love.graphics.setColor(game.color.blue)
                love.graphics.rectangle("fill", x, y, 1, 1)
            end

        end
    end

    -- Jetties
    love.graphics.setColor(game.color.yellow)
    for _, jetty in ipairs(game.lake.jetties) do
        love.graphics.rectangle("fill", jetty.x, jetty.y, 1, 1)
    end

    -- Player boat
    if showPlayer and game.logic.player.x then
        love.graphics.setColor(game.color.base3)
        love.graphics.rectangle("fill", game.logic.player.x, game.logic.player.y, 1, 1)
    end

    love.graphics.pop()
    love.graphics.setCanvas()

    return preview

end

return module
