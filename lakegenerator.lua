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


--- Place jetties on a map conforming to a contour.
function module:placeJetties(a, contour, seed, density)

  seed = seed or os.time()
  math.randomseed(seed)

  local width, height = #contour, #contour[1]
  local amount = width * height * density

  while amount > 0 do

    -- find a random open point on the contour
    local x, y = 1, 1
    while contour[x][y] > 0 do
      x = math.random(1, width-1)
      y = math.random(1, height-1)
    end

    -- find the shoreline in a random direction
    local offsetx = math.random(-1, 1)

    if offsetx == 0 then
      -- left by default
      offsetx = -1
    end

    -- move in direction until we hit land
    while contour[x+offsetx][y] == 0 do
      x = x + offsetx
    end

    -- this spot is a jetty
    a[x][y] = 1
    amount = amount - 1

  end

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
  array2d:populateBlocks(data.contour, seed, density)
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
  array2d:populateBlocks(data.depth, seed, density - 0.1)
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
  data.jetties = array2d:array(width, height)
  self:placeJetties(data.jetties, data.contour, seed, 0.002)  -- n% of the surface

  return data

end

return module
