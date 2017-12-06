--[[
   fish.lua

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
    for _, fish in ipairs(game.lake.fish) do
        love.graphics.setColor(0, 128, 255, 64)
        if fish.track then
            love.graphics.setColor(255, 128, 255, 255)
        end
        if fish.feeding then
            love.graphics.draw(game.view.tiles.image, game.view.tiles.fish.feed,
                fish.screenX, fish.screenY)
        else
            love.graphics.draw(game.view.tiles.image, game.view.tiles.fish.home,
                fish.screenX, fish.screenY)
        end
    end
end

return module
