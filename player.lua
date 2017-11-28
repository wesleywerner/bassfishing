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

local module = {}
local glob = require("globals")
local array2d = require("array2d")

--- Find a jetty as the launch zone
function module:launchBoat()
    
    if not glob.lake then
        error("Cannot launch the boat if there is no lake to fish on")
    end

    -- pick a random jetty
    self.jetty = glob.lake.jetties[ math.random(1, #glob.lake.jetties) ]
    
    -- test for surrounding open water
    local tests = {
        {   -- left
            x = math.max(1, self.jetty.x - 2),
            y = self.jetty.y
        },
        {   -- right
            x = math.min(glob.lake.width, self.jetty.x + 2),
            y = self.jetty.y
        },
        {   -- top
            x = self.jetty.x,
            y = math.max(1, self.jetty.y - 2)
        },
        {   -- bottom
            x = self.jetty.x,
            y = math.min(glob.lake.height, self.jetty.y + 2)
        },
    }
    
    for _, test in ipairs(tests) do
        if glob.lake.contour[test.x][test.y] == 0 then
           self.mapX = test.x
           self.mapY = test.y
        end
    end
    
end

return module