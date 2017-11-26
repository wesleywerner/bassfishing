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

local array2d = require("array2d")
local module = {}


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
        a[x][y] = 1

      end
    end
  end

end


--- Place jetties on a map conforming to a contour.
function module:placeJetties(a, seed)

  local list = {}

  for i=1, 4 do
    -- next seed since we are in a loop
    seed = seed + 1
    local coastalpoint = array2d:findCoastline(a, seed)
    table.insert(list, coastalpoint)
  end

  return list

end

--- Create some water obstacles
function module:createObstacles(a, seed)

  seed = seed or os.time()
  math.randomseed(seed)

  local list = {}

  for i=1, 30 do
    -- next seed since we are in a loop
    seed = seed + 10
    local coastalpoint = array2d:findCoastline(a, seed)

    -- is it a rock, a log or a moored boat?
    local what = math.random(1, 3)
    if what == 1 then
      coastalpoint.rock = true
    elseif what == 2 then
      coastalpoint.log = true
    else
      coastalpoint.boat = true
    end

    -- avoid placing over other obstacles
    local duplicate = false
    for obsi, obs in ipairs(list) do
      if coastalpoint.x == obs.x and coastalpoint.y == obs.y then
        duplicate = true
      end
    end

    if not duplicate then
      table.insert(list, coastalpoint)
    end

  end

  return list

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

  -- generate the water depth: a 2D boolean array where shallow is "true".
  -- reduce evolution iterations to make it more "ragged".
  -- (psst: it is a contour map with a higher density)
  data.depth = array2d:array(width, height)
  array2d:noise(data.depth, seed, density + 0.1)
  self:largeNoise(data.depth, seed, density - 0.1)
  array2d:cellulate(data.depth, math.floor(iterations / 3))

  -- generate aquatic plants
  -- reuse the depth map, the idea being plants grow in shallow waters.
  -- we also number each island of plants to easier draw groups of same sprites.
  data.plants = array2d:copy(data.depth)
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

  -- place jetties
  data.jetties = self:placeJetties(data.contour, seed)

  -- add obstacles (logs, rocks, moored boats)
  data.obstacles = self:createObstacles(data.contour, seed)

  -- remove obstacles covering jetties
  for obsi, obs in ipairs(data.obstacles) do
    for _, jetty in ipairs(data.jetties) do
      if obs.x == jetty.x and obs.y == jetty.y then
        table.remove(data.obstacles, obsi)
      end
    end
  end


  return data

end

return module
