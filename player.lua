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

local module = {
    speed = 0
}

local boat = require("boat")
local lume = require("lume")
local states = require("states")
local messages = require("messages")
local tiles = require("tiles")


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

--- Calculate the boat cruising speed by the distance on-screen from it's goal position
function module:findBoatSpeed(dt)
        
    -- distance to the goal
    local distanceToGoal = lume.distance(self.screenX, self.screenY, self.screenGoalX, self.screenGoalY)
    
    --distanceToGoal = lume.round(distanceToGoal, 0.1)
    
    -- work in tile units
    local currentSpeed = math.floor(distanceToGoal / (tiles.size / 2))
    
    -- compensate for diagonal movement (which counts as more tiles)
    local isdiagonal = self.angleTo % 90 == 45
    if isdiagonal then
        currentSpeed = math.max(0, currentSpeed - 1)
    end
    
    -- take the current speed if faster, otherwise gradually reduce the boat speed
    if currentSpeed > self.speed then
        self.speed = currentSpeed
        -- clear engine cut-off timer
        self.engineCutoff = nil
    elseif self.speed > 0 then
        -- clamp to 1 to simulate the boat idling
        self.speed = math.max(1, self.speed - dt)
    end
        
    -- if the boat is idling use a timer to cut the engine off
    if currentSpeed == 0 and self.speed == 1 then
        
        self.engineCutoff = (self.engineCutoff or 5) - (dt)
        if self.engineCutoff < 0 then
            self.speed = 0
            self.engineCutoff = nil
        end

    end
    
    return distanceToGoal

end


function module:update(dt)
    
    -- update player boat screen position and angle
    boat:update(self, dt)
    
    local distanceToGoal = self:findBoatSpeed(dt)

    -- show a crunch screen
    if self.stuck then
        -- but only when the boat is near it's goal on screen (compensates for movement lerping)
        if distanceToGoal < 8 then

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