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

local module = {}

local glob = require("globals")
local lume = require("lume")
local tiles = require("tiles")

--- Prepare a boat
function module:prepare(boat)

    -- movement counter
    boat.frame = 0

    -- current boat angle
    boat.angle = 0

    -- lerp the angle from this
    boat.angleFrom = 0

    -- lerp the angle to this
    boat.angleTo = 0

    -- lerp progress
    boat.angleFrame = 0

    -- the boat is stuck after hitting the shore or an obstacle. we can only reverse out.
    boat.stuck = false

    -- position on screen in pixels
    boat.screenX = nil
    boat.screenY = nil

    boat.color = boat.color or {255, 255, 255}

end

--- Find a jetty as the launch zone
function module:launchBoat(boat)

    if not glob.lake then
        error("Cannot launch the boat if there is no lake to fish on")
    end

    -- pick a random jetty
    math.randomseed(os.time())
    boat.jetty = glob.lake.jetties[ math.random(1, #glob.lake.jetties) ]

    -- test for surrounding open water
    local tests = {
        {   -- left
            x = math.max(1, boat.jetty.x - 2),
            y = boat.jetty.y
        },
        {   -- right
            x = math.min(glob.lake.width, boat.jetty.x + 2),
            y = boat.jetty.y
        },
        {   -- top
            x = boat.jetty.x,
            y = math.max(1, boat.jetty.y - 2)
        },
        {   -- bottom
            x = boat.jetty.x,
            y = math.min(glob.lake.height, boat.jetty.y + 2)
        },
    }

    for _, test in ipairs(tests) do
        if glob.lake.contour[test.x][test.y] == 0 then
           boat.x = test.x
           boat.y = test.y
        end
    end

    -- clear the boat screen position so it can be launched at the correct place
    boat.screenX = nil
    boat.screenY = nil

end

--- Updates the boat on-screen position
function module:update(boat, dt)

    -- the screen position goal
    boat.screenGoalX = ((boat.x - 1) * tiles.size) + tiles.center
    boat.screenGoalY = ((boat.y - 1) * tiles.size) + tiles.center

    -- start in-place if the screen position is empty
    if not boat.screenX or not boat.screenY then
        boat.screenX = boat.screenGoalX
        boat.screenY = boat.screenGoalY
    end

    -- remember the old position, and reset the movement counter when this changes
    if boat.fromScreenX ~= boat.screenGoalX or boat.fromScreenY ~= boat.screenGoalY then
        boat.fromScreenX = boat.screenX
        boat.fromScreenY = boat.screenY
        boat.frame = 0  -- TODO: rename to movementFrame
    end

    -- lerp the boat position
    boat.frame = boat.frame + dt * 4
    boat.screenX = lume.lerp(boat.fromScreenX, boat.screenGoalX, boat.frame)
    boat.screenY = lume.lerp(boat.fromScreenY, boat.screenGoalY, boat.frame)

    -- lerp the boat angle
    boat.angleFrame = boat.angleFrame + dt * 2
    boat.angle = lume.lerp(boat.angleFrom, boat.angleTo, boat.angleFrame)

end

--- Turn the boat
function module:turn(boat, turnangle)

    boat.angleFrom = boat.angleTo
    boat.angleTo = (boat.angleTo + turnangle)
    boat.angleFrame = 0

end

function module:left(boat)
    if not boat.stuck then
        self:turn(boat, -45)
    end
    boatAI:move()
end

function module:right(boat)
    if not boat.stuck then
        self:turn(boat, 45)
    end
    boatAI:move()
end

--- Gets the new position of a boat given it's direction (1 forward, -1 reverse).
function module:getNextPosition(boat, dir)

    -- 45       90      135
    -- 0        BOAT    180
    -- 315      270     225

    local direction = boat.angleTo % 360

    -- store new positions temporarily
    local nextX = boat.x
    local nextY = boat.y

    -- flip positive and negative movement. allows going forward and backward with this function.
    local neg = - dir
    local pos = dir

    if direction == 0 then
        -- west
        nextX = boat.x + neg
    elseif direction == 45 then
        -- north west
        nextX = boat.x + neg
        nextY = boat.y + neg
    elseif direction == 90 then
        -- north
        nextY = boat.y + neg
    elseif direction == 135 then
        -- north east
        nextX = boat.x + pos
        nextY = boat.y + neg
    elseif direction == 180 then
        -- east
        nextX = boat.x + pos
    elseif direction == 225 then
        -- south east
        nextX = boat.x + pos
        nextY = boat.y + pos
    elseif direction == 270 then
        -- south
        nextY = boat.y + pos
    elseif direction == 315 then
        -- south west
        nextX = boat.x + neg
        nextY = boat.y + pos
    end

    -- clamp to the map size
    nextX = lume.clamp(nextX, 1, glob.lake.width)
    nextY = lume.clamp(nextY, 1, glob.lake.height)

    return nextX, nextY

end


--- Move the boat
function module:move(boat, dir)

    -- store last known good position before moving
    boat.previousX = boat.x
    boat.previousY = boat.y

    -- apply the new position
    boat.x, boat.y = self:getNextPosition(boat, dir)

    -- get any obstacles at the new position
    boat.stuck = self:getObstacle(boat)

end

-- Move forward
function module:forward(boat)
    self:move(boat, 1)
end

-- Move backward
function module:reverse(boat)
    self:move(boat, -1)
end

--- Undo the last move
function module:undoMove(boat)
    if boat.previousX and boat.previousY then
       boat.x = boat.previousX
       boat.y = boat.previousY
    end
end


--- Returns an obstacle at a map position including jetties and land.
function module:getObstacle(boat)

    local lake = glob.lake
    local x, y = boat.x, boat.y

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

    -- include other boats except the current
    for _, craft in ipairs(lake.boats) do
        if craft.x == x and craft.y == y and craft ~= boat then
            return craft
        end
    end

end

--- Returns the distance in pixels the boat is from it's goal.
function module:distanceToGoal(boat)

    return lume.distance(boat.screenX, boat.screenY, boat.screenGoalX, boat.screenGoalY)

end

--- Calculates the boat speed.
-- dt is used because speed is determined by how often the boat is moved
-- in real time.
function module:calculateSpeed(boat, dt)

    -- distance to the goal
    boat.distanceToGoal = self:distanceToGoal(boat)

    -- work in tile units
    local currentSpeed = math.floor(boat.distanceToGoal / (tiles.size / 2))

    -- compensate for diagonal movement which counts as more tiles
    -- and we don't want that
    local isdiagonal = boat.angleTo % 90 == 45
    if isdiagonal then
        currentSpeed = math.max(0, currentSpeed - 1)
    end

    -- take the current speed if faster, otherwise gradually reduce the speed
    if currentSpeed > boat.speed then
        boat.speed = currentSpeed
        -- clear engine cut-off timer
        boat.engineCutoff = nil
    elseif boat.speed > 0 then
        -- clamp to 1 to simulate the boat idling
        boat.speed = math.max(1, boat.speed - dt)
    end

    -- if the boat is idling use a timer to cut the engine off
    if currentSpeed == 0 and boat.speed == 1 then

        boat.engineCutoff = (boat.engineCutoff or 5) - (dt)
        if boat.engineCutoff < 0 then
            boat.speed = 0
            boat.engineCutoff = nil
        end

    end

end

return module
