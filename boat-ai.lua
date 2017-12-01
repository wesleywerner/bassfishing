--[[
   boat-ai.lua

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

local module = {}
local glob = require("globals")
local lume = require("lume")
local boat = require("boat")


function module:update(dt)

    for _, craft in ipairs(glob.lake.boats) do
        if craft.AI then
            boat:update(craft, dt)
        end
    end

end

--- Move all the boats
function module:move()

    for _, craft in ipairs(glob.lake.boats) do

        if craft.AI then

            -- move forward
            boat:forward(craft)

            -- the boat has collided with something
            if craft.stuck then
                -- undo that move
                boat:undoMove(craft)
                -- chance of staying put
                if math.random() < 0.05 then
                    -- turn the boat around
                    boat:turn(craft, math.random(-2, 2) * 45)
                end
            else
                -- chance of changing course
                if math.random() < 0.1 then
                    -- turn the boat around
                    local adjustCourse = math.random(-1, 1) * 45
                    boat:turn(craft, adjustCourse)
                end
            end

        end
    end

end

return module
