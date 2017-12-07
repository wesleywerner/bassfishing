--[[
   lakegenerator.lua

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
local lume = require("libs.lume")
local array2d = require("logic.array2d")
local boat = require("logic.boat")
local fishAI = require("logic.fish")
local luastar = require("libs.lua-star")

--- Adds large chunks of noise simulating land mass
--
-- @tparam table a
-- The array to fill.
--
-- @tparam number seed
-- The random seed.
--
-- @tparam number density
-- Percent of array width to try cover.
function module:largeNoise(a, seed, density)

    seed = seed or os.time()
    math.randomseed(seed)

    local width = #a
    local height = #a[1]
    local iterations = width * density

    for iteration=1, iterations do

        -- random position
        local blockx = math.random(1, width)
        local blocky = math.random(1, height)
        local blockw = math.floor(math.random(1, width * 0.2))  -- % of size
        local blockh = math.floor(math.random(1, height * 0.2))

        for offsetx=1, blockw do
            for offsety=1, blockh do
                -- wrap around
                local x = math.max(1, (blockx + offsetx) % width)
                local y = math.max(1, (blocky + offsety) % height)
                a[x][y] = math.random()
            end
        end

    end

end


--- Place jetties on a map conforming to a contour.
function module:placeJetties(data, seed)

    data.jetties = {}

    for i=1, 4 do
        -- next seed since we are in a loop
        seed = seed + 1
        local coastalpoint = array2d:findCoastline(data.contour, seed)
        coastalpoint.jetty = true
        table.insert(data.jetties, coastalpoint)
    end

end

--- Create some water obstacles
function module:createObstacles(data, seed)

    seed = seed or os.time()
    math.randomseed(seed)

    data.obstacles = {}

    for i=1, 30 do

        -- next seed since we are in a loop
        seed = seed + 10
        local coastalpoint = array2d:findCoastline(data.contour, seed)

        -- is it a rock, a log or a moored boat?
        local what = math.random(1, 2)
        if what == 1 then
            coastalpoint.rock = true
        elseif what == 2 then
            coastalpoint.log = true
        end

        -- avoid placing over other obstacles
        local skip = false
        for obsi, obs in ipairs(data.obstacles) do
            if coastalpoint.x == obs.x and coastalpoint.y == obs.y then
                skip = true
            end
        end

        -- remove obstacles covering jetties
        for _, jetty in ipairs(data.jetties) do
            if coastalpoint.x == jetty.x and coastalpoint.y == jetty.y then
                skip = true
            end
        end

        if not skip then
            table.insert(data.obstacles, coastalpoint)
        end

    end

end

--- Build some boats
function module:createBoats(data, seed)

    seed = seed or os.time()
    math.randomseed(seed)

    data.boats = {}

    local colors = {
        {224, 0, 0},
        {0, 224, 0},
        {224, 224, 224},
        {224, 0, 224},
        {224, 224, 0},
    }

    local boatAmount = math.random(10, 20)

    for i=1, boatAmount do

        -- next seed since we are in a loop
        seed = seed + 10

        -- find a random open point
        local x, y = 0, 0
        repeat
            x = math.random(1, data.width - 1)
            y = math.random(1, data.height - 1)
        until data.contour[x][y] == 0

        -- assign a random color
        local boatcolor = colors[math.random(1, #colors)]

        -- avoid placing over other boats
        local skip = false
        for _, b in ipairs(data.boats) do
          if b.x == x and b.y == y then
            skip = true
          end
        end

        if not skip then
            table.insert(data.boats, {
                x = x,
                y = y,
                color = boatcolor,
                boat = true,
                AI = true
            })
        end
    end

    -- prepare the boats
    for _, craft in ipairs(data.boats) do
        boat:prepare(craft)
    end

end

--- Build some boats
function module:spawnFish(data, seed)

    seed = seed or os.time()
    math.randomseed(seed)

    -- underwater structure is a map array
    data.structure = array2d:array(data.width, data.height, false)
    data.fish = {}

    -- size up how much open water the lake has (count open water tiles)
    local volume = 0
    for x=1, data.width do
        for y=1, data.height do
            if data.contour[x][y] == 0 then
                volume = volume + 1
            end
        end
    end

    -- fill n% with structure
    local coverage = math.floor(volume * 0.1)

    -- track unique fish number
    local fishid = 1

    for coverid=1, coverage do

        -- find a random tile
        local x, y = 0, 0
        repeat
            x = math.random(1, data.width - 1)
            y = math.random(1, data.height - 1)
        until data.contour[x][y] == 0

        -- deeper waters have a n% chance of having structure.
        -- depth 0 is nearer the bottom.
        local sanctuary = data.depth[x][y] < 0.4 and math.random() < 0.5

        data.structure[x][y] = sanctuary

        -- spawn some fish here
        if sanctuary then

            local fishes = math.random(0, 5)

            for n=1, fishes do

                local fish = fishAI:newFish(x, y)
                fish.id = fishid
                fish.feedingZones = self:spawnFishFeedingZones(data, x, y)
                table.insert(data.fish, fish)
                fishid = fishid + 1

            end

        end

    end

end


--- Return a list of paths to feeding zones near a position.
function module:spawnFishFeedingZones(data, x, y)

    -- the number of feeding zones a fish can have
    local numberOfFeedingZones = 3

    -- the maximum distance a fish will travel to a feeding zone (in map coordinates)
    local maxFeedingZoneDistance = 10

    -- stores the list of paths to feeding zones
    local listOfPaths = { }

    -- map a list of feeding points to each aquatic plant
    local nearbyPlants = { }

    array2d:iter(data.plants,
        function(value, px, py)
            -- this point has plants
            return value > 0
        end,
        function(value, px, py)
            -- include a point if within feeding range
            local dist = lume.distance(x, y, px, py)
            if dist <= maxFeedingZoneDistance then
                table.insert(nearbyPlants, { x = px, y = py, distance = dist })
            end
            -- preserve the plant array data, we don't need to change it
            return value
        end)

    -- path finding callback to return true if a position is open to walk
    local getMapPositionOpen = function(x, y)
        return data.contour[x][y] == 0
    end

    local done = false

    while not done do

        -- get a random plant point from the list of nearby plants
        local id = math.random(1, #nearbyPlants)
        local plantPoint = table.remove(nearbyPlants, id)

        -- get a path to this point
        local start = { x = x, y = y }
        local goal = { x = plantPoint.x, y = plantPoint.y }
        local path = luastar:find( data.width, data.height, start, goal, getMapPositionOpen, false)

        -- the path length must be within range.
        -- a plant can be nearby on the map, but could be seperated by a land mass
        -- so we have to ensure a fish won't travel too far to get to it.
        if #path <= maxFeedingZoneDistance then
            table.insert( listOfPaths, path )
        end

        -- stop when we have enough paths, or if we run out of points to test
        if #listOfPaths == numberOfFeedingZones or #nearbyPlants == 0 then
            done = true
        end

    end

    return listOfPaths

end

--- Return a new generated map
function module:generate(width, height, seed, density, iterations)

    local data = {}
    data.width = width
    data.height = height
    data.seed = seed
    data.density = density
    data.iterations = iterations

    -- generate the contour map: a 2D boolean array where land is "true".
    data.contour = array2d:array(width, height)
    -- add random noise to start our contours
    array2d:noise(data.contour, seed, density)
    -- add variety by placing some random land masses (or plain blocks if you prefer)
    self:largeNoise(data.contour, seed, density)
    -- close off the map with a border
    array2d:addBorder(data.contour)
    -- put it through cellular evolution
    array2d:cellulate(data.contour, iterations)
    -- fill in the gaps
    array2d:fillHoles(data.contour)

    -- generate the water depth (values 0..1 where 1 is near the surface)
    data.depth = array2d:array(width, height)
    array2d:noise(data.depth, seed, density + 0.1)
    self:largeNoise(data.depth, seed, density + 0.2)
    array2d:cellulate(data.depth, iterations)
    -- smooth out the water bed
    array2d:average(data.depth)

    -- generate aquatic plants
    -- number each island of plants to draw groups of the same sprite.
    data.plants = array2d:array(width, height)
    array2d:noise(data.plants, seed, density + 0.01)
    self:largeNoise(data.plants, seed, density + 0.05)
    array2d:cellulate(data.plants, math.floor(iterations / 6))
    array2d:clipExcludeContour(data.plants, data.contour)
    array2d:numberRegions(data.plants)

    -- generate trees (cellular evolution around the contour)
    data.trees = array2d:array(width, height)
    array2d:noise(data.trees, seed, 0.45) -- n% of the surface
    array2d:cellulate(data.trees, 6)
    array2d:clipIncludeContour(data.trees, data.contour)
    array2d:numberRegions(data.trees)

    -- generate buildings (dotted around the contour)
    data.buildings = array2d:array(width, height)
    array2d:noise(data.buildings, seed, 0.01)  -- n% of the surface
    array2d:clipIncludeContour(data.buildings, data.contour)

    -- place launching docks
    self:placeJetties(data, seed)

    -- empty placeholders for boats, fish obstacles and structure
    data.boats = { }
    data.fish = { }
    data.obstacles = { }
    data.structure = array2d:array(width, height, false)

    return data

end

--- Add fish, competitor boats, lake structure and obstacles
function module:populateLakeWithFishAndBoats(data)

    self:createObstacles(data, data.seed)
    self:createBoats(data, data.seed)
    self:spawnFish(data, data.seed)

end

return module
