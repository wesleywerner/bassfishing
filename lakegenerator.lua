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
        a[x][y] = math.random()

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
    coastalpoint.jetty = true
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
    local what = math.random(1, 2)
    if what == 1 then
      coastalpoint.rock = true
    elseif what == 2 then
      coastalpoint.log = true
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

--- Build some boats
function module:createBoats(a, seed)

    seed = seed or os.time()
    math.randomseed(seed)

    local width, height = #a, #a[1]
    local list = {}
    local colors = {
        {224, 0, 0},
        {0, 224, 0},
        {224, 224, 224},
        {224, 0, 224},
        {224, 224, 0},
    }

    for i=1, 30 do

        -- next seed since we are in a loop
        seed = seed + 10

        -- find a random open point on the contour
        local x, y = 0, 0
        repeat
            x = math.random(1, width-1)
            y = math.random(1, height-1)
        until a[x][y] == 0

        -- assign a random color
        local boatcolor = colors[math.random(1, #colors)]

        -- avoid placing over other boats
        local duplicate = false
        for _, b in ipairs(list) do
          if b.x == x and b.y == y then
            duplicate = true
          end
        end

        if not duplicate then
            table.insert(list, {
                x=x,
                y=y,
                screenX=(x-1)*16,   -- TODO: set to zero and update with AI module
                screenY=(y-1)*16,
                angle=0,
                color=boatcolor,
                boat=true
            })
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

  -- place jetties
  data.jetties = self:placeJetties(data.contour, seed)

  -- add obstacles (logs, rocks, moored boats)
  data.obstacles = self:createObstacles(data.contour, seed)

  -- add other boats
  data.boats = self:createBoats(data.contour, seed)

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
