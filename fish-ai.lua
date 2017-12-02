--[[
   fish-ai.lua

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

--[[

    http://www.umpquavalleybassmasters.com/bassbook.htm

    * "You may find structure which at the moment is not holding bass
    but you will NEVER find bass without structure."

    *  The larger the bass become, the more likely they are to prefer
    deeper water and the harder it is for fishermen to find them.

    * To find relief from bright light the bass must head for the
    depths and remain at some level where sunlight cannot penetrate or
    retreat into the shaded comfort of "colored" water or places where
    there are expanses of very heavily matted bottom weed-beds, lily
    pads, submerged brush, or felled trees.

    * Reduced light penetration, such as during low-light periods of
    early morning or late evening or even after dark, might see the
    bass move to shallower water upon occasion. Cold front weather
    conditions might see them move considerably deeper! As a general
    rule, bass will go as deep as need be to feel safe and avoid bright
    light.

    * The place where a school of bass rests in deep water between
    feeding cycles is called the sanctuary.

    * Because the sanctuary is normally in deeper water, pinpointing
    its exact location is nearly impossible.

    * When in the sanctuary, the school of bass is in a rather inactive
    state and can seldom be tempted into biting or provoked into
    striking.

    * The school of bass will occasionally, most frequently on a
    schedule, migrate or travel from the sanctuary to some other area a
    short distance away, usually into somewhat shallower water, and
    they are now in a highly active feeding state.

    * The largemouth seems most comfortable when the water is between
    65 and 75 F. As the water chills, their metabolism starts to slow
    down and in cold water bass are very sluggish.

    * Bass become uncomfortable when the water temperatures rise above
    80. That's when the bass will be found along shaded or windy
    shorelines where wave action pumps oxygen into the water, or among
    aquatic plants which produce oxygen.

    * Bass need not to be feeding for you to catch them; instincts
    other than hunger will cause them to strike. Mere curiosity, an
    instinctive attack reaction

    * Weather has far more effect on fishermen than on fish anywhere.
    If you can find bass at all, it is possible to catch them whether
    it is raining and windy or calm with bright sunshine.

    * The importance of fishing a lure close to the bottom cannot be
    overemphasized.

    * The more quietly an angler behaves, the better his chances.
    Banging a tackle box against the bottom of a boat, having creaky or
    loose oarlocks, rowing or paddling with splashing action, and other
    noise producing activities are to be avoided because they frighten
    the bass. When frightened, the bass become uneasy and on-guard and
    either quickly leave the area or cease feeding.

    * As a bass gets bigger, it gets tougher to fool.

]]--

local module = {

    -- % chance a fish decides to seek food
    chanceToFeed = 0.05,    -- 0.01  -- TODO: reset chanceToFeed

    -- the minimum depth underneath aquatic plants for fish to consider it a feeding zone
    -- (bottom 0>1 surface)
    --feedingZoneDepth = 0.4,

    -- distance (in map coordinates) to stay near the feeding zone
    feedingRadius = 0,

    -- distance (in map coordinates) to stay near home
    sanctuaryRadius = 0,

}

local array2d = require("array2d")
local glob = require("globals")
local lume = require("lume")

--- Returns a new fish object
function module:newFish(x, y)

    -- fish size is a weighted chance
    local weight = 0
    local size = lume.weightedchoice({
        ["small"] = 10,
        ["medium"] = 5,
        ["large"] = 2 })

    -- set weight based on size
    if size == "small" then
        weight = lume.round( lume.random(0.3, 0.9), 0.01)
    elseif size == "medium" then
        weight = lume.round( lume.random(1, 1.9), 0.01)
    else
        weight = lume.round( lume.random(2, 5), 0.01)
    end

    return {
        x = x,
        y = y,
        size = size,
        weight = weight,

        -- fish return the their sanctuary when not feeding
        sanctuary = { x=x, y=y },

        -- fish can be spooked by loud noises while feeding (outboard motors, boat collisions)
        spooked = false,

        -- hungry fish seek out shallower waters especially where there is aquatic plants
        feeding = false,
        feedingZone = {},
    }

end

--- Update all fish
function module:move()

    for _, fish in ipairs(glob.lake.fish) do

        if fish.feeding then

            if self:swimToFeed(fish) then

                -- the fish is satieted
                if math.random() < (self.chanceToFeed * 2) then
                    fish.feeding = false
                end

            end

        else

            -- move back to the sanctuary
            if self:swimHome(fish) then

                -- fish is home and getting hungry
                fish.feeding = math.random() < self.chanceToFeed

                if fish.feeding then
                    self:assignNearestFeedingZone(fish)
                end

            end

        end

    end

end

--- Assign the nearest feeding zone to a fish.
function module:assignNearestFeedingZone(fish)

    -- get a list of all aquatic plant islands
    local plantIslands = array2d:getListOfIslands(glob.lake.plants)

    -- sorry fish, no feeding areas for you :(
    if #plantIslands == 0 then return end

    -- get the distance to each plant island
    for _, island in ipairs(plantIslands) do
        island.distance = lume.distance(fish.x, fish.y, island.pos.x, island.pos.y)
    end

    -- sort by nearest distance first
    table.sort(plantIslands, function(a, b) return a.distance < b.distance end)

    -- pick a random top(n) feeding zone
    local topchoice = math.random(1, math.min(#plantIslands, 3) )
    local favoriteIsland = plantIslands[topchoice]

    -- now we find a random point inside the chosen island (patches of aquatic plants can cover large areas)

    -- make a copy of the plants map (it gets destroyed with flood fill)
    local plantmap = array2d:copy(glob.lake.plants)

    -- get all the points in this island
    local fillSize, filledPoints = array2d:floodFill( plantmap,
        favoriteIsland.pos.x, favoriteIsland.pos.y, favoriteIsland.pos.value, 0 )

    -- pick a random position inside the island area
    local luckyPoint = filledPoints[ math.random(1, #filledPoints) ]

    fish.feedingZone = { x=luckyPoint.x, y=luckyPoint.y }
    self:debug(fish, "heading to zone " .. topchoice, "at", luckyPoint.x, luckyPoint.y)

end

--- Move a fish closer to it's sanctuary.
function module:swimHome(fish)

    local distanceToHome = lume.distance(fish.x, fish.y, fish.sanctuary.x, fish.sanctuary.y)
    if distanceToHome <= self.sanctuaryRadius then
        return true
    end

    if fish.x < fish.sanctuary.x then
        fish.x = fish.x + 1
    elseif fish.x > fish.sanctuary.x then
        fish.x = fish.x - 1
    end

    if fish.y < fish.sanctuary.y then
        fish.y = fish.y + 1
    elseif fish.y > fish.sanctuary.y then
        fish.y = fish.y - 1
    end

    return false

end

--- Move a fish closer to it's feeding zone.
-- Returns true when in the zone
function module:swimToFeed(fish)

    local distanceToZone = lume.distance(fish.x, fish.y, fish.feedingZone.x, fish.feedingZone.y)
    if distanceToZone <= self.feedingRadius then
        return true
    end

    if fish.x < fish.feedingZone.x then
        fish.x = fish.x + 1
    elseif fish.x > fish.feedingZone.x then
        fish.x = fish.x - 1
    end

    if fish.y < fish.feedingZone.y then
        fish.y = fish.y + 1
    elseif fish.y > fish.feedingZone.y then
        fish.y = fish.y - 1
    end

    return false

end

function module:debug(fish, message)
    if fish.track then
        print(message)
    end
end


return module
