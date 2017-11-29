--[[
   boat.lua

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
    
    -- current boat angle
    angle = 0,
    -- lerp the angle from this
    angleFrom = 0,
    -- lerp the angle to this
    angleTo = 0,
    -- lerp progress
    angleFrame = 0,
    -- the boat is stuck after hitting the shore or an obstacle. we can only reverse out.
    stuck = false,
}

local glob = require("globals")
local array2d = require("array2d")
local lume = require("lume")
local genie = require("lakegenerator")
local states = require("states")
local messages = require("messages")

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
    
    -- clear the boat screen position so it can be launched at the correct place
    self.screenX = nil
    self.screenY = nil
end

--- Updates the boat on-screen position
function module:update(dt)
    
    -- the screen position goal
    self.screenGoalX = (self.mapX -1) * 16
    self.screenGoalY = (self.mapY -1) * 16
    
    -- the player starts in-place if the screen position is empty
    if not self.screenX or not self.screenY then
        self.screenX = self.screenGoalX
        self.screenY = self.screenGoalY
    end
        
    -- remember the old position, and reset the movement counter when this changes
    if self.fromScreenX ~= self.screenGoalX or self.fromScreenY ~= self.screenGoalY then
        self.fromScreenX = self.screenX
        self.fromScreenY = self.screenY
        self.frame = 0
    end
    
    -- lerp the boat position
    self.frame = self.frame + dt * 4
    self.screenX = lume.lerp(self.fromScreenX, self.screenGoalX, self.frame)
    self.screenY = lume.lerp(self.fromScreenY, self.screenGoalY, self.frame)
    
    -- lerp the boat angle
    self.angleFrame = self.angleFrame + dt * 2
    self.angle = lume.lerp(self.angleFrom, self.angleTo, self.angleFrame)
    
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
            
            states:push("crunch", { title="CRUNCH!!!!", message=template, shake=true } )
            
            -- auto reverse out of the pickle
            self.mapX = self.previousMapX
            self.mapY = self.previousMapY
            self.stuck = false
        end
    end
    
    
end

--- Turn the boat
function module:turn(turnangle)
    
    self.angleFrom = self.angleTo
    self.angleTo = (self.angleTo + turnangle)
    self.angleFrame = 0
    
end

function module:left()
    if not self.stuck then
        self:turn(-45)
    end
end

function module:right()
    if not self.stuck then
        self:turn(45)
    end
end

--- Move the boat
function module:move(dir)
    
    -- 45       90      135
    -- 0        BOAT    180
    -- 315      270     225
    
    -- prevent movement while stuck until the crunch screen has shown.
    -- this also prevents a boat zooming over obstacles without crunching into them
    -- since moving into open water while stuck is a valid move.
    if self.stuck then
        return
    end
    
    local direction = self.angleTo % 360
    
    -- store new positions temporarily
    local newMapX = self.mapX
    local newMapY = self.mapY
    
    -- flip positive and negative movement. allows going forward and backward with this function.
    local neg = - dir
    local pos = dir
    
    if direction == 0 then
        -- west
        newMapX = self.mapX + neg
    elseif direction == 45 then
        -- north west
        newMapX = self.mapX + neg
        newMapY = self.mapY + neg
    elseif direction == 90 then
        -- north
        newMapY = self.mapY + neg
    elseif direction == 135 then
        -- north east
        newMapX = self.mapX + pos
        newMapY = self.mapY + neg
    elseif direction == 180 then
        -- east
        newMapX = self.mapX + pos
    elseif direction == 225 then
        -- south east
        newMapX = self.mapX + pos
        newMapY = self.mapY + pos
    elseif direction == 270 then
        -- south
        newMapY = self.mapY + pos
    elseif direction == 315 then
        -- south west
        newMapX = self.mapX + neg
        newMapY = self.mapY + pos
    end
    
    -- store last known good position before moving
    self.previousMapX = self.mapX
    self.previousMapY = self.mapY
    
    -- apply the new position
    if not self.stuck then
        self.mapX = newMapX
        self.mapY = newMapY
    end

    -- get any obstacles at the new position
    self.stuck = self:getObstacle(glob.lake, newMapX, newMapY)
    
end

-- Move forward
function module:forward()
    self:move(1)
end

-- Move backward
function module:reverse()
    self:move(-1)
end

--- Returns an obstacle at a map position including jetties and land.
function module:getObstacle(lake, x, y)
    
    for _, obstacle in ipairs(lake.obstacles) do
        if obstacle.x == x and obstacle.y == y then
            return obstacle
        end
    end
    
    -- include jetties
    for _, jetty in ipairs(lake.jetties) do
        if jetty.x == x and jetty.y == y then
            return jetty
        end
    end
    
    -- include land
    if lake.contour[x][y] > 0 then
        local nearBuilding = lake.buildings[x][y] > 0
        
        return {
            x=x,
            y=y,
            land=true,
            building=nearBuilding
        }
    end
    
end


return module