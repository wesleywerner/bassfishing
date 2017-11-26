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
function module:placeJetties(contour, seed)

  seed = seed or os.time()
  math.randomseed(seed)

  local list = {}
  local width, height = #contour, #contour[1]
  local amount = width * height * 0.002

  while amount > 0 do

    -- find a random open point on the contour
    local x, y = 1, 1
    while contour[x][y] > 0 do
      x = math.random(1, width-1)
      y = math.random(1, height-1)
    end

    -- find the shoreline in a random direction
    local ox, oy = 0, 0

    -- move either up/down or left/right
    repeat
      ox, oy = math.random(-1, 1), math.random(-1, 1)
    until (ox == 0 and oy ~= 0) or (ox ~= 0 and oy == 0)

    -- move in direction until we hit land
    while contour[x+ox][y+oy] == 0 do
      x = x + ox
      y = y + oy
    end

    -- this spot is a jetty
    table.insert(list, {
      x=x,
      y=y,
      horizontal=ox ~= 0,
      vertical=oy ~= 0
    })

    -- count down to the next jetty
    amount = amount - 1

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

  -- generate buildings (dotted around the contour)
  data.buildings = array2d:array(width, height)
  array2d:noise(data.buildings, seed, 0.01)  -- n% of the surface
  array2d:clipIncludeContour(data.buildings, data.contour)

  -- place jetties
  data.jetties = self:placeJetties(data.contour, seed)

  return data

end

return module
