--[[
   bass fishing
   tournament.lua

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

local module = { }

-- The tournament day
module.day = 0

--- The tournament clock
-- os.time(number-of-seconds) returns the number of seconds since the epoch.
-- Providing os.time('!*t', number-of-seconds) gives a table (*t)
-- and (!) as UTC, otherwise the hour component will be offset by our timezone.
--
-- return table.foreach(os.date('!*t', 3665), print) -- 1hr, 1min, 5sec
--    hour  1
--    min   1
--    sec   5
--    year  1970
--
-- Get the formatted time:
--  os.date("!%H:%M:%S", number-of-seconds)
--
-- (!) ensures UTC time
--
-- http://www.cplusplus.com/reference/ctime/strftime/

-- Get the readable date with os.date("%c", instance.date)
module.time = 0

-- The formatted time
module.timef = "00:00:00"

-- Warn the player when this much time is left
module.timeWarning = 60 * 60    -- 60 mins

-- Track if the warning has shown for this day
module.displayedWarning = false

-- The tournament score card
module.standings = nil

-- Records the largest fish weighed each day
module.lunkerOfTheDay = nil

-- Keeps a list of all fish weighed by the player over the tournament
module.fishStatistics = nil


--- Start the tournament.
-- Sets up the time, weather, lake.
function module:start()

    self.day = 0

    -- clear the list of fish caught by the player
    self.fishStatistics = { }

    -- generate the list of angler standings
    -- assume each boat has two anglers
    self.standings = game.logic.competitors:getNames(#game.lake.boats * 2)

    -- include the player
    table.insert(self.standings, {
        name = game.logic.player.name,
        player = true,
        lake = game.logic.player.lake
        })

    -- advance the day
    self:nextDay()

    -- reset player
    game.logic.player:resetTour()

    game.dprint("The tournament has begun!")

end

function module:disable()

    self.day = 0

end

--- Begin the next day of the tournament
function module:nextDay()

    -- ensure the angler standings have values
    for _, angler in ipairs(self.standings) do
        -- reset the daily catch
        angler.dailyWeight = 0
        angler.totalWeight = angler.totalWeight or 0
    end

    -- move to the next day
    self.day = self.day + 1

    -- reset the clock
    self.time = 60 * 60 * 6     -- 6 hours
    self.timef = os.date("!%H:%M", self.time)

    -- reset the 30 minute remain warning flag
    self.displayedWarning = false

    -- reset player
    game.logic.player:resetDay()

    -- clear the daily lunker
    self.lunkerOfTheDay = nil

    -- launch the player boat from a jetty
    game.logic.boat:launchBoat(game.logic.player)

    -- change the weather
    game.logic.weather:change()

end

--- Move the competitors, fish and clock.
function module:turn(optionalMinutes)

    game.logic.fish:move()
    game.logic.competitors:move()
    self:takeTime(optionalMinutes or 1)

end

-- Reduce the tournament clock
function module:takeTime(minutes)

    if self.day == 0 then return end

    self.time = math.max(0, self.time - (minutes * 60))
    self.timef = os.date("!%H:%M", self.time)

    if self.time <= self.timeWarning and not self.displayedWarning then
        self.displayedWarning = true
        game.view.notify:add("60 minutes before weigh-in!", true)
    end

end

function module:recordDailyLunker(angler, fish)

    if not self.lunkerOfTheDay or fish.weight > self.lunkerOfTheDay.weight then
        self.lunkerOfTheDay = {
            name = angler.name,
            weight = fish.weight
        }
    end

end

--- Weighs the player and competitor fish
function module:endOfDay()

    game.dprint("\nWeighing player and competitor catches")

    -- list of top lunkers caught by the player (not daily lunkers)
    local playerLunkers = { }

    -- player alias
    local player = game.logic.player

    -- share out remaining fish
    local fishper = math.floor(#game.lake.fish / #self.standings)

    -- process player and competitor catches of the day
    for _, angler in ipairs(self.standings) do

        if angler.player then

            -- the player is near the weigh-in area
            if player.nearJetty then

                -- weigh the fish in the live well
                for _, fish in ipairs(game.logic.livewell.contents) do

                    -- store fish data for statistics
                    table.insert(self.fishStatistics, {
                        weight=fish.weight,
                        lure="TODO" -- TODO: record fish lure
                    })

                    angler.dailyWeight = angler.dailyWeight + fish.weight
                    self:recordDailyLunker(angler, fish)

                    -- record in the top lunkers (returns false if no record is entered)
                    local newRecord = game.logic.toplunkers:recordLunker(
                        player.name, player.lake, fish.weight)

                    -- keep the new top record
                    if newRecord then
                        table.insert(playerLunkers, newRecord)
                    end

                end

            end

        else

            -- share out the remaining fish between competitors
            for n=1, fishper do
                local fish = table.remove(game.lake.fish)
                angler.dailyWeight = angler.dailyWeight + fish.weight
                self:recordDailyLunker(angler, fish)
            end

        end

    end

    -- add up total weights
    for _, angler in ipairs(self.standings) do
        angler.totalWeight = angler.totalWeight + angler.dailyWeight
        game.dprint(string.format("angler: %s, daily: %.2f, total: %.2f",
            angler.name, angler.dailyWeight, angler.totalWeight))
    end

    -- empty the live well
    game.logic.livewell:empty()

    -- add fish to the lake again
    game.logic.genie:spawnFish(game.lake, game.lake.seed)

    -- push the the top lunkers state
    -- (this state is displayed last, it is a state stack, remember?)
    if #playerLunkers > 0 then
        -- save the top lunker list
        game.logic.toplunkers:save()
        game.dprint(string.format("You made %d top lunkers!", #playerLunkers))
        game.logic.toplunkers:printLunkerList()
        game.states:push("top lunkers", playerLunkers)
    end

    -- push the tournament results state
    -- (this state is displayed after weigh in)
    if game.logic.tournament.day == 3 then

        -- sort standings by total weight
        table.sort(self.standings, function(a, b)
        return a.totalWeight > b.totalWeight end)

        -- find the player standing
        local playerstanding = 0
        for i, angler in ipairs(self.standings) do
            if angler.player then
                playerstanding = i
            end
        end

        -- record tournament statistics
        game.logic.stats:record(self.fishStatistics, player.lake,
        playerstanding, game.logic.player.castsCount)

        -- queue the tournament results state
        game.states:push("tournament results")

    end

    -- push the weigh in state
    game.states:push("weigh in")

end


return module
