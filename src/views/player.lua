--[[
   player.lua

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

function module:drawBoat()

    local player = game.logic.player
    love.graphics.setColor(0, 255, 255)

    -- the boat
    love.graphics.draw(game.view.tiles.image, game.view.tiles.boats[3],
        player.screenX, player.screenY, math.rad(player.angle), 1, 1,
        8, 8 )

    -- the casting crosshair
    if player.castOffset then

        -- cast crosshair
        love.graphics.setColor(0, 255, 255)
        love.graphics.circle("line", player.castOffset.screenX,
            player.castOffset.screenY, 4)

        -- cast range
        love.graphics.setColor(0, 255, 255, 16)
        love.graphics.circle("fill", player.screenX, player.screenY, player.castRange * game.view.tiles.size)

    end

    -- the cast line
    if player.castLine then
        love.graphics.setColor(255, 255, 255, player.castLine.fade * 255 )
        love.graphics.setLineWidth(1)
        love.graphics.line(player.screenX, player.screenY, unpack(player.castLine.points))
    end

end

function module:drawRodDetails()
    love.graphics.setFont(game.fonts.small)
    love.graphics.setColor(game.fonts.color)
    love.graphics.print("Flip rod with chartreuse rapala")
end

return module
