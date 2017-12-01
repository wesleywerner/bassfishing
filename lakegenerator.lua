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
local lume = require("lume")
local array2d = require("array2d")
local boat = require("boat")
local fishAI = require("fish-ai")

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

            for fishid=1, fishes do
                table.insert(data.fish, fishAI:newFish(x, y))
            end

        end

    end
    
    -- debug
    --table.sort(data.fish, function(a, b) return a.weight < b.weight end)
    --for _, fish in ipairs(data.fish) do
    --    print(fish.size, fish.weight)
    --end

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

    self:placeJetties(data, seed)
    self:createObstacles(data, seed)
    self:createBoats(data, seed)
    self:spawnFish(data, seed)

    return data

end

return module
