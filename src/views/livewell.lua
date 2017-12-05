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

local glob = require("logic.globals")
local tiles = require("views.tiles")
local livewell = require("logic.livewell")
local module = { }

function module:draw()

    -- width used to right-align printed text
    local w, h = 160, 150

    love.graphics.setFont(glob.fonts.medium)
    love.graphics.setColor(glob.fonts.color)

    for i, fish in ipairs(livewell.contents) do
        local py = (i - 1) * 24
        love.graphics.draw(tiles.image, tiles.fish[fish.size], 0, py)
        love.graphics.printf(string.format("%.2f kg", fish.weight), 0, py, w, "right")
    end

end

return module
