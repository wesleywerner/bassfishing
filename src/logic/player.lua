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

    -- current boat cruising speed
    speed = 0,

    -- maximum boat speed
    maxSpeed = 10,

    -- flag when the trolling motor is in use
    trolling = false,

    -- the factor (in tiles) to multiply outboard speed to get the
    -- range to scare away fish
    outboardNoiseFactor = 2,

    -- casting offset
    castOffset = nil,

    -- the cast line drawn on screen
    castLine = nil,

    -- the distance to be near the weigh-in jetty (in map coordinates)
    minDistanceToJetty = 2,

    -- current distance to jetty
    distanceFromJetty = 0,

    -- player name
    name = "Player",

    -- name of the lake the player is fishing
    lake = "Wes's Pond",

    -- records the number of casts made
    castsCount = 0,

    -- selected rod description for status text
    rodDescription = "",

    -- boat speed description for status text
    speedDescription = nil
}

--- Set the rod and lure description
local function setRodDescription()

    if module.rod then
        if module.rod.lure then
            module.rodDescription = string.format("%s, %s %s",
            module.rod.name,
            module.rod.lure.color,
            module.rod.lure.name)
        else
            module.rodDescription = string.format("%s", module.rod.name)
        end
    else
        module.rodDescription = "No rod selected"
    end

end

--- Turn the boat left
function module:left()
    if not self.stuck then
        game.logic.boat:turn(self, -45)
        game.logic.tournament:turn(0.5)
    end
end

--- Turn the boat right
function module:right()
    if not self.stuck then
        game.logic.boat:turn(self, 45)
        game.logic.tournament:turn(0.5)
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

    game.logic.boat:forward(self)
    self:getDistanceFromJetty()

    -- if using outboard then spook nearby fish
    if not self.trolling then
        self:spookNearbyFish()
    end

    -- the outboard motor uses less time the faster you go.
    -- ensure we always use a minimum speed of 1.
    if self.trolling then
        game.logic.tournament:turn()
    else
        game.logic.tournament:turn(1 / math.max(1, self.speed) )
    end

    return true

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

    game.logic.boat:reverse(self)
    self:getDistanceFromJetty()

    -- if using outboard then spook nearby fish
    if not self.trolling then
        self:spookNearbyFish()
    end

    game.logic.tournament:turn()

    return true

end

function module:getDistanceFromJetty()

    self.distanceFromJetty = game.lib.trig:distance(self.x, self.y, self.jetty.x, self.jetty.y)

    self.nearJetty = self.distanceFromJetty <= self.minDistanceToJetty

end

--- Returns if the cursor is aimed outside the cast range
function module:aimPastRange(x, y)

    -- yes if no cast offset is set
    if not self.castOffset then return true end

    -- yes if no rod is selected
    if not self.rod then return true end

    local distance = game.lib.trig:distance(self.x, self.y, x, y)

    return distance > self.rod.range

end

function module:aimCast( x, y )

    if not self.screenX then return end

    -- no rod to cast with
    if not game.logic.player.rod then return end

    -- no lure to cast with
    if not game.logic.player.rod.lure then return end

    -- origin is the player boat position
    local range = self.rod.range * game.view.tiles.size
    x, y = game.lib.trig:limitPointToCircle(self.screenX, self.screenY, x, y, range)

    self.castOffset = {
        screenX = x,
        screenY = y,
        x = 1 + math.floor(x / game.view.tiles.size),
        y = 1 + math.floor(y / game.view.tiles.size)
        }

end

function module:cast()

    -- test if there is a cast aimed
    if not self.castOffset then return end

    -- still reeling in the line
    if self.castLine then return end

    -- retake aim in case boat is moving
    self:aimCast(self.castOffset.screenX, self.castOffset.screenY)

    -- you hooked your partner's hat!
    local distance = math.floor(game.lib.trig:distance(self.screenX, self.screenY, self.castOffset.screenX, self.castOffset.screenY))
    if distance < 5 then
        game.dprint("you hooked your partner's hat!")
        game.states:push("messagebox", { title="OOPS", message="You hooked your partner's hat!", shake=false } )
        return
    end

    -- count casts made
    self.castsCount = self.castsCount + 1

    -- see if the fish wants to strike
    local fish = game.logic.fish:attemptStrike(self.castOffset.x, self.castOffset.y, self.rod.lure)

    -- record the lure used
    if fish then
        fish.lure = string.format("%s %s", self.rod.lure.color, self.rod.lure.name)
    end

    -- set the cast line
    self.castLine = {
        x = self.castOffset.x,
        y = self.castOffset.y,
        points = { self.castOffset.screenX, self.castOffset.screenY },
        fade = 1,
        fish = fish
    }

    -- take time
    game.logic.tournament:turn()

    game.sound:play("cast")

    -- randomly play plop sound
    if math.random() > 0.98 then
        game.sound:play("plop")
    end

end

--- Remove a fish from the water
function module:pullFishFromWater(fish)

    for i, f in ipairs(game.lake.fish) do
        if f.id == fish.id then
            table.remove(game.lake.fish, i)
        end
    end

end

--- Land a fish that striked
function module:landFish(fish)

    -- remove the fish from the pond
    self:pullFishFromWater(fish)

    local release, lwmessage = game.logic.livewell:add(fish)

    -- release the fish, it will swim back home
    if release then
        release.track = true
        -- set the fish draw position to the player's for a smooth transition
        release.screenX, release.screenY = nil, nil
        game.logic.fish:releaseFishIntoLake(release, self.x, self.y)
    end

    local message = string.format("%s fish landed\n%s",
    game.lib.convert:weight(fish.weight), lwmessage)

    game.view.notify:add(message, { icon=game.view.tiles.fish.large })

    game.sound:play("fish on")

end

function module:update(dt)

    -- update player boat screen position and angle
    game.logic.boat:update(self, dt)

    -- work out boat cruising speed and distance to the goal
    game.logic.boat:calculateSpeed(self, dt)

    if self.trolling then
        self.speedDescription = nil
    else
        if self.speed > 3 then
            self.speedDescription = "full throttle"
        elseif self.speed > 2 then
            self.speedDescription = "speeding"
        elseif self.speed > 1 then
            self.speedDescription = "cruising"
        elseif self.speed > 0.1 then
            self.speedDescription = "going slow"
        elseif self.speed == 0.1 then
            self.speedDescription = "idling"
        else
            self.speedDescription = nil
        end
    end

    -- retake aim in case boat is moving
    if self.castOffset and self.speed > 0.1 then
        self:aimCast(self.castOffset.screenX, self.castOffset.screenY)
    end

    if not self.trolling and self.speed > 0 then
        -- boat speeds:
        -- > 3 is full throttle
        -- > 2 is speeding
        -- > 1 is cruising
        -- > 0.1 is slow
        -- 0.1 is idling

        -- the motor pitch:
        -- 1 is normal
        -- 0.5 is one octave lower
        -- 2 is one octave higher

        game.sound:play("outboard", true)

        if self.speed > 3 then
            -- full throttle
            game.sound:pitch("outboard", 1.5)
        elseif self.speed > 2 then
            -- speeding
            game.sound:pitch("outboard", 1.25)
        elseif self.speed > 1 then
            -- cruising
            game.sound:pitch("outboard", 1)
        elseif self.speed > 0.1 then
            -- going slow
            game.sound:pitch("outboard", 0.75)
        elseif self.speed == 0.1 then
            -- idling
            game.sound:pitch("outboard", 0.5)
        end

    else
        game.sound:stop("outboard")
    end

    -- reel in cast line
    if self.castLine then

        -- the reel-in speed
        self.castLine.fade = self.castLine.fade - dt * 3.5

        if self.castLine.fade < 0 then

            -- there is a fish on the line!
            if self.castLine.fish then
                self:landFish(self.castLine.fish)
            end

            -- we can snag on ground
            if game.lake.contour[self.castLine.x][self.castLine.y] > 0 then
                if math.random() < 0.5 then
                    game.states:push("messagebox", { title="", message="You nearly lost your bait on a snag." } )
                else
                    game.states:push("messagebox", { title="", message="You lost your bait on a snag. You lose 5 minutes tying a new lure." } )
                    -- take the time away
                    game.logic.tournament:takeTime(5)
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
            local messages = game.view.messages

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

            game.states:push("messagebox", { title="CRUNCH!!!!", message=template, shake=true } )

            -- take the time away
            game.logic.tournament:takeTime(timelost)

            -- auto reverse out of the pickle
            game.logic.boat:undoMove(self)
            self.stuck = false

            -- make noise that scares fish away
            self:spookNearbyFish(2)

        end
    end

end

--- Reset the player cast aiming and launch distance
function module:resetDay()

    self.speed = 0
    self.castLine = nil
    self.castOffset = nil
    self.distanceFromJetty = 1

end

--- Reset the player angling statistics
function module:resetTour()

    self.castsCount = 0
    setRodDescription()

end

function module:setLure(category, name, color)

    if self.rod then

        self.rod.lure = {
            name = name,
            color = color,
            category = category
        }

        game.dprint(string.format("set player lure as %s %s (%s)", color, name, category))

        setRodDescription()

        -- take the time
        game.logic.tournament:takeTime(3)

    else
        game.dprint("Warning: cannot set a lure when no rod is chosen.")
    end

end

function module:setRod(rod)

    self.rod = rod

    -- clear the cast aim, in case this rod does not have a lure set
    -- we don't want to draw the cast range.
    self.castOffset = nil

    -- select rod
    game.dprint(string.format("selected %s", rod.name))

    setRodDescription()

    -- take the time
    game.logic.tournament:takeTime(1)

end

function module:toggleTrollingMotor()

    if not self.trolling and self.speed > 0 then
        game.view.notify:add("Your outboard must stop before you can switch to trolling")
        return false
    end

    self.trolling = not self.trolling

    if self.trolling then
        self.maxSpeed = 0.5
        game.dprint("\nTrolling motor is now used")
    else
        self.maxSpeed = 10
        game.dprint("\nOutboard motor is now used")
    end

    return true

end

function module:spookNearbyFish(optionalRange)

    -- range of noise in map coordinates
    local noiseRange = (optionalRange or math.max(1, self.speed)) * self.outboardNoiseFactor

    -- find fish in this range
    local nearfish = game.logic.fish:findFishInRange(self.x, self.y, noiseRange)

    for _, fish in ipairs(nearfish) do
        game.logic.fish:spookFish(fish)
    end

end

--- Move towards a given map point using path finding
function module:moveTowardsPoint(x, y)

    -- wait until the boat angle has normalized
    if self.angle < 0 or self.angle > 360 then return end
    if self.angle % 45 ~= 0 then return end

    -- path finding callback to return true if a position is open to walk
    local getMapPositionOpen = function(x, y)

        local isopen = true

        for _, obstacle in ipairs(game.lake.obstacles) do
            if obstacle.x == x and obstacle.y == y then
                isopen = false
            end
        end

        if not isopen then return false end

        -- include jetties
        for _, jetty in ipairs(game.lake.jetties) do
            if jetty.x == x and jetty.y == y then
                isopen = false
            end
        end

        if not isopen then return false end

        -- test the land contour
        return game.lake.contour[x][y] == 0

    end

    -- get a path to this point
    local start = { x = self.x, y = self.y }
    local goal = { x = x, y = y }
    local path = game.lib.luastar:find(game.lake.width, game.lake.height, start, goal, getMapPositionOpen, false)

    if path and #path > 1 then

        -- first point is where we are now. take the second
        local goal = path[2]

        -- angle the boat towards the first point.
        -- if the angle is good, move the boat.
        local goalAngle = math.deg(game.lib.trig:angle(goal.x, goal.y, self.x, self.y))

        goalAngle = goalAngle % 360
        if goalAngle < 0 then goalAngle = goalAngle + 360 end

        --print(string.format("angle to point %.1f, our boat is %.1f", goalAngle, self.angle))

        -- move or turn the boat
        if self.angle == goalAngle then
            self:forward()
        elseif goalAngle > 180 and self.angle < 135 then
            -- shortcut through 360
            self:left()
        elseif goalAngle < 135 and self.angle > 225 then
            -- shortcut through 360
            self:right()
        elseif goalAngle < self.angle then
            self:left()
        elseif goalAngle > self.angle then
            self:right()
        end

    end

end


return module
