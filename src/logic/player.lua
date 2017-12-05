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

local boat = require("logic.boat")
local lume = require("libs.lume")
local states = require("logic.states")
local messages = require("views.messages")
local glob = require("logic.globals")
local livewell = require("logic.livewell")
local fishAI = require("logic.fish-ai")
local tiles = require("views.tiles")

local module = {

    -- current boat cruising speed
    speed = 0,

    -- maximum boat speed
    maxSpeed = 10,

    -- casting offset
    castOffset = nil,

    -- maximum cast range (in map coordinates)
    castRange = 4 * tiles.size,

    -- the cast line drawn on screen
    castLine = nil,
}

--- Turn the boat left
function module:left()
    if not self.stuck then
        boat:turn(self, -45)
    end
end

--- Turn the boat right
function module:right()
    if not self.stuck then
        boat:turn(self, 45)
    end
end

--- Move the boat forward
function module:forward()
    -- prevent movement while stuck until the crunch screen has shown.
    -- this also prevents a boat zooming over obstacles without crunching into them
    -- since moving into open water while stuck is a valid move.
    if self.stuck then
        return
    end

    -- limit speed (when using a trolling motor etc)
    if self.speed > self.maxSpeed then
        return
    end

    boat:forward(self)

    -- clear the cast aim
    self.castOffset = nil

end

-- --- Move the boat backward
function module:reverse()
    -- prevent movement while stuck until the crunch screen has shown.
    -- this also prevents a boat zooming over obstacles without crunching into them
    -- since moving into open water while stuck is a valid move.
    if self.stuck then
        return
    end

    -- limit speed (when using a trolling motor etc)
    if self.speed > self.maxSpeed then
        return
    end

    boat:reverse(self)

    -- clear the cast aim
    self.castOffset = nil

end

function module:aimCast( x, y )

    if not self.screenX then return end

    -- origin is the player boat position
    x, y = glob:limitPointToCircle(self.screenX, self.screenY, x, y, self.castRange)
    self.castOffset = {
        screenX = x,
        screenY = y,
        x = 1 + math.floor(x / tiles.size),
        y = 1 + math.floor(y / tiles.size)
        }

end

function module:cast()

    -- test if there is a cast aimed
    if not self.castOffset then return end

    -- still reeling in the line
    if self.castLine then return end

    -- TODO: provide lure data to the strike
    local lure = { color = "green" }
    local fish = fishAI:attemptStrike(self.castOffset.x, self.castOffset.y, lure)

    -- set the cast line
    self.castLine = {
        x = self.castOffset.x,
        y = self.castOffset.y,
        points = { self.castOffset.screenX, self.castOffset.screenY },
        fade = 1,
        fish = fish
    }

end

--- Land a fish that striked
function module:landFish(fish)

    -- remove the fish from the pond
    for i, f in ipairs(glob.lake.fish) do
        if f.id == fish.id then
            table.remove(glob.lake.fish, i)
        end
    end

    local release, lwmessage = livewell:add(fish)

    -- release the fish, it will swim back home
    if release then
        release.track = true
        -- set the fish draw position to the player's for a smooth transition
        release.screenX, release.screenY = nil, nil
        fishAI:releaseFishIntoLake(release, self.x, self.y)
    end

    local message = string.format("You landed a %s fish of %.2f kg\n\n%s", fish.size, fish.weight, lwmessage)

    states:push("message", { title="FISH ON", message=message, shake=false } )

end

function module:update(dt)

    -- update player boat screen position and angle
    boat:update(self, dt)

    -- work out boat cruising speed and distance to the goal
    boat:calculateSpeed(self, dt)

    -- reel in cast line
    if self.castLine then

        self.castLine.fade = self.castLine.fade - dt * 2
        if self.castLine.fade < 0 then

            -- there is a fish on the line!
            if self.castLine.fish then
                self:landFish(self.castLine.fish)
            end

            -- we can snag on ground
            if glob.lake.contour[self.castLine.x][self.castLine.y] > 0 then
                if math.random() < 0.5 then
                    states:push("message", { title="", message="You nearly lost your bait on a snag." } )
                else
                    states:push("message", { title="", message="You lost your bait on a snag. You lose 5 minutes tying a new lure." } )
                end
            end

            -- clear the cast line, ready to cast again
            self.castLine = nil

        end

    end

    -- show a crunch screen
    if self.stuck then

        -- but only when the boat is near it's goal on screen
        -- compensates for movement lerping so the message won't show until
        -- the boat is next to whatever it hit.
        if self.distanceToGoal < 8 then

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
