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
    -- a timer that counts down until we show the crunch screen
    crunchTimer = 0,
}

local glob = require("globals")
local array2d = require("array2d")
local lume = require("lume")
local genie = require("lakegenerator")
local states = require("states")

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
    if self.stuck and self.crunchTimer > 0 then
        -- but only when the boat is near it's goal on screen (compensates for movement lerping)
        if lume.distance(self.screenX, self.screenY, self.screenGoalX, self.screenGoalY) < 1 then
            self.crunchTimer = self.crunchTimer - dt
            if self.crunchTimer < 0 then
                states:push("crunch", {whatdidyouhit="foo"})
            end
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
    
    -- get any obstacle at the new position
    local obstructed = genie:getObstacle(glob.lake, newMapX, newMapY)
    
    if not obstructed then
        self.mapX = newMapX
        self.mapY = newMapY
        self.stuck = false
    elseif obstructed.land then
        -- prevent moving onto land
        self.stuck = true
        -- set a timer to show a crunch screen
        self.crunchTimer = 0.1
    elseif obstructed then
        -- allow moving onto other obstructions, except when we are already stuck
        if not self.stuck then
            self.mapX = newMapX
            self.mapY = newMapY
        end
        self.stuck = true
        -- set a timer to show a crunch screen
        self.crunchTimer = 0.4
    end
    

end

-- Move forward
function module:forward()
    self:move(1)
end

-- Move backward
function module:reverse()
    self:move(-1)
end




return module