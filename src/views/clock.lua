--[[
   clock.lua

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

    -- print day and time
    love.graphics.setColor(game.color.white)
    love.graphics.setFont(game.fonts.small)
    love.graphics.print(string.format("Day %d", game.logic.tournament.day), 0, 0)
    love.graphics.printf(game.logic.tournament.timef, 0, 0, 150, "right")

end

return module
