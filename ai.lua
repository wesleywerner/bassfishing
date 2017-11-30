--[[
   ai.lua

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
--local array2d = require("array2d")
local lume = require("lume")


function module:update(dt)

    for _, boat in ipairs(glob.lake.boats) do

        -- the screen position goal
        boat.screenGoalX = (boat.x -1) * 16
        boat.screenGoalY = (boat.y -1) * 16

        -- the player starts in-place if the screen position is empty
        if not boat.screenX or not boat.screenY then
            boat.screenX = boat.screenGoalX
            boat.screenY = boat.screenGoalY
        end

        -- remember the old position, and reset the movement counter when this changes
        if boat.fromScreenX ~= boat.screenGoalX or boat.fromScreenY ~= boat.screenGoalY then
            boat.fromScreenX = boat.screenX
            boat.fromScreenY = boat.screenY
            boat.moveFrame = 0
        end

        -- lerp the boat position
        boat.moveFrame = boat.moveFrame + dt * 4
        boat.screenX = lume.lerp(boat.fromScreenX, boat.screenGoalX, boat.moveFrame)
        boat.screenY = lume.lerp(boat.fromScreenY, boat.screenGoalY, boat.moveFrame)

        -- lerp the boat angle
        boat.angleFrame = boat.angleFrame or 0
        boat.angleTo = boat.angleTo or 0
        boat.angleFrom = boat.angleFrom or 0
        boat.angleFrame = boat.angleFrame + dt * 2
        boat.angle = lume.lerp(boat.angleFrom, boat.angleTo, boat.angleFrame)

    end

end

--- Move all the boats
function module:move()

    for _, boat in ipairs(glob.lake.boats) do
        self:moveBoat(boat)
    end

end

--- Move a single boat
function module:moveBoat(boat)

    -- 45       90      135
    -- 0        BOAT    180
    -- 315      270     225

    local direction = boat.angleTo % 360

    -- store new positions temporarily
    local newMapX = boat.x
    local newMapY = boat.y

    local neg = -1
    local pos = 1

    if direction == 0 then
        -- west
        newMapX = boat.x + neg
    elseif direction == 45 then
        -- north west
        newMapX = boat.x + neg
        newMapY = boat.y + neg
    elseif direction == 90 then
        -- north
        newMapY = boat.y + neg
    elseif direction == 135 then
        -- north east
        newMapX = boat.x + pos
        newMapY = boat.y + neg
    elseif direction == 180 then
        -- east
        newMapX = boat.x + pos
    elseif direction == 225 then
        -- south east
        newMapX = boat.x + pos
        newMapY = boat.y + pos
    elseif direction == 270 then
        -- south
        newMapY = boat.y + pos
    elseif direction == 315 then
        -- south west
        newMapX = boat.x + neg
        newMapY = boat.y + pos
    end

    -- get any obstacles at the new position
    local obstruction = self:getObstacle(glob.lake, newMapX, newMapY)

    if obstruction then
        -- chance of staying here
        if math.random() < 0.05 then
            -- turn the boat around
            self:turn(boat, math.random(-2, 2) * 45)
        end
    else
        -- apply the new position
        boat.x = newMapX
        boat.y = newMapY
        -- chance of changing course
        if math.random() < 0.1 then
            -- turn the boat around
            local adjustCourse = math.random(-1, 1) * 45
            -- ensure we adjust towards the current angle sign
            --if boat.angleTo < 0 then
            --    adjustCourse = adjustCourse * -1
            --end
            self:turn(boat, adjustCourse)
        end
    end

end

function module:turn(boat, turnangle)

    boat.angleFrom = boat.angleTo
    boat.angleTo = (boat.angleTo + turnangle)
    boat.angleFrame = 0

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

    -- include other boats
    for _, boat in ipairs(lake.boats) do
        if boat.x == x and boat.y == y then
            return boat
        end
    end

end

return module
