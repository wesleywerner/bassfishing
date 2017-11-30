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
local boat = require("boat")
local lume = require("lume")
local states = require("states")
local messages = require("messages")


function module:left()
    if not self.stuck then
        boat:turn(self, -45)
    end
end

function module:right()
    if not self.stuck then
        boat:turn(self, 45)
    end
end

function module:forward()
    -- prevent movement while stuck until the crunch screen has shown.
    -- this also prevents a boat zooming over obstacles without crunching into them
    -- since moving into open water while stuck is a valid move.
    if self.stuck then
        return
    end

    boat:forward(self)
end

-- Move backward
function module:reverse()
    -- prevent movement while stuck until the crunch screen has shown.
    -- this also prevents a boat zooming over obstacles without crunching into them
    -- since moving into open water while stuck is a valid move.
    if self.stuck then
        return
    end

    boat:reverse(self)
end


function module:update(dt)
    
    -- update player boat screen position and angle
    boat:update(self, dt)

    -- show a crunch screen
    if self.stuck then
        -- but only when the boat is near it's goal on screen (compensates for movement lerping)
        if lume.distance(self.screenX, self.screenY, self.screenGoalX, self.screenGoalY) < 8 then

            -- customize the obstruction message
            local timelost = math.random(4, 10)
            local template = ""
            if self.stuck.building then
                template = string.format(messages["building collision"], timelost)
            elseif self.stuck.land then
                template = string.format(messages["land collision"], timelost)
            elseif self.stuck.rock then
                template = string.format(messages["severe rock collision"], timelost)
            elseif self.stuck.log then
                template = string.format(messages["log collision"], timelost)
            elseif self.stuck.boat then
                template = string.format(messages["boat collision"], timelost)
            elseif self.stuck.jetty then
                template = string.format(messages["jetty collision"], timelost)
            end

            states:push("message", { title="CRUNCH!!!!", message=template, shake=true } )

            -- auto reverse out of the pickle
            boat:undoMove(self)
            self.stuck = false
        end
    end
    
end

return module