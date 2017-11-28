--[[
   array2d.lua

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

--- Provides functions to manipulate 2D arrays.
-- Included are functions to apply cellular automata rules to these arrays.
--
-- These references came in very handy in writing this code:
--
-- Excellent noise generation page:
-- http://lodev.org/cgtutor/randomnoise.html
--
-- Nice tutorial implementing cellular automata:
-- https://gamedevelopment.tutsplus.com/tutorials/generate-random-cave-levels-using-cellular-automata--gamedev-9664
--
-- Good old rogue basin for cave generation:
-- http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels
--
-- @module array2d

local module = {}

--- Create a 2D array.
--
-- @tparam number width
-- The width of the array.
--
-- @tparam number height
-- The height of the array.
--
-- @tparam object default
-- Default value to initialise values.
--
-- @treturn table
-- An indexed table as a 2D array.
function module:array(width, height, default)

  local a = {}
  default = default or 0

  for x=1, width do
    a[x] = {}
    for y=1, height do
      a[x][y] = default
    end
  end

  return a

end

--- Iterate over an array.
--
-- @tparam table a
-- The array to iterate.
--
-- @tparam function test
-- function(value, x, y)
-- A function that should return true if assignment is to proceed.
--
-- @tparam function assignment
-- function(value, x, y)
-- A function that should return the new value to assign.
--
-- @treturn table
function module:iter(a, test, assignment)

  local width, height = #a, #a[1]
  for x=1, width do
    for y=1, height do
      if test(a[x][y], x, y) then
        a[x][y] = assignment(a[x][y], x, y)
      end
    end
  end

end

--- Fill an array with random noise.
-- This preserves the value of untouched cells.
--
-- @tparam table a
-- The array to fill.
--
-- @tparam number seed
-- The random seed.
--
-- @tparam number density
-- Weight of the chance of placing a value, 0>n>1
function module:noise(a, seed, density)

  seed = seed or os.time()
  math.randomseed(seed)

  self:iter(a,
    function(value)
      return math.random() < density
    end,
    function(value)
      return math.random()  -- used to return 1
    end
    )

end

--- Count neighbouring cells of a map point.
-- Only counts a neighbour if it's value is non zero.
--
-- @tparam table a
-- Array to reference.
--
-- @tparam number px
-- x position to test.
--
-- @tparam number py
-- y position to test.
--
-- @treturn number
-- Count of neighbours with non-zero values.
function module:countNeighbours(a, px, py)

  local width = #a
  local height = #a[1]
  local count = 0
  local average = 0
  
  
  for ix=-1,1 do
    for iy=-1,1 do
      if ix == 0 and iy == 0 then
        -- skip counting ourselves
      else
        local nx = px+ix
        local ny = py+iy
        -- consider a boundary as a positive.
        -- this helps to fill in the edges of the map.
        if nx < 1 or ny < 1 or nx > width or ny > height then
          -- comment the line below to generate open-sea like islands
          count = count + 1
        elseif a[nx][ny] > 0 then
          -- count if this neighbour is positive
          count = count + 1
          average = average + a[nx][ny]
        end
      end
    end
  end
  return count, (average / count)

end

--- Apply cellular automata to a map
function module:cellulate(a, iterations)

  -- tweakers:
  -- the deathLimit is a good tweak.

  -- minimum living neighbours to survive (for living cells)
  local deathLimit = 4
  -- minimum living neighbours to reproduce (for dead cells)
  local birthLimit = 4

  local width = #a
  local height = #a[1]

  -- work-on copy
  local b = self:array(width, height)

  for iter=1, iterations do
    for x=1, width do
      for y=1, height do
        -- this cell is alive if truthy
        local alive = a[x][y] > 0
        -- copy the cell
        b[x][y] = a[x][y]
        -- count neighbours at this point
        local neighbours, average = self:countNeighbours(a, x, y)
        -- alone cells die off without enough neighbours
        if alive and neighbours < deathLimit then
          -- the cell dies
          b[x][y] = 0
        elseif not alive and neighbours > birthLimit then
          -- a new cell is born
          b[x][y] = average
        end
      end
    end

    -- copy results
    for x=1, width do
      for y=1, height do
        a[x][y] = b[x][y]
      end
    end

  end -- do another iteration

end

--- Place a border around the array
function module:addBorder(a)

  local width = #a
  local height = #a[1]

  for x=1, width do
    a[x][1] = 1
    a[x][height] = 1
  end
  for y=1, height do
    a[1][y] = 1
    a[width][y] = 1
  end

end

--- Copy an array
function module:copy(a)
  local width, height = #a, #a[1]
  local b = self:array(width, height)
  for x=1, width do
    for y=1, height do
      b[x][y] = a[x][y]
    end
  end
  return b
end

--- Fills all but the largest hole on a map.
function module:fillHoles(a)

  local holes = self:getListOfHoles(a)

  -- sort the list, smallest hole first
  table.sort(holes, function(a, b)
    return a.size < b.size
  end)

  -- remove the largest hole from the list
  table.remove(holes)

  -- fill the remaining holes on the original array
  for _, hole in ipairs(holes) do
    self:floodFill(a, hole.pos.x, hole.pos.y, 0, 1)
  end

end


--- Assign a number to each island in a map.
function module:numberRegions(a)

  -- to make this work, we must ensure that all values in the array
  -- won't clash with our numbering scheme. we change all non-zero
  -- values to a temporary value first.
  self:iter(a,
    function(value)
      return value > 0
    end,
    function(value)
      return 1000
    end)

  local regions = self:getListOfIslands(a)

  for i, reg in ipairs(regions) do
    self:floodFill(a, reg.pos.x, reg.pos.y, 1000, i)
  end

end


--- Get a list of holes in a map.
function module:getListOfHoles(a)

  local width, height = #a, #a[1]

  -- make a list of all the holes in the map and their size.
  -- we use a copy of the map for this, as it will destroy the map.
  local cp = self:copy(a)
  local list = {}
  local nexthole = self:findHole(cp)

  while nexthole ~= nil do
    local filledSize = self:floodFill(cp, nexthole.x, nexthole.y, 0, 1)
    table.insert(list, { pos=nexthole, size=filledSize })
    nexthole = self:findHole(cp)
  end

  return list

end

--- Get a list of islands in a map.
function module:getListOfIslands(a)

  local width, height = #a, #a[1]

  -- make a list of all the holes in the map and their size.
  -- we use a copy of the map for this, as it will destroy the map.
  local cp = self:copy(a)
  local list = {}
  local nextisland = self:findIsland(cp)

  while nextisland ~= nil do
    local filledSize = self:floodFill(cp, nextisland.x, nextisland.y, nextisland.value, 0)
    table.insert(list, { pos=nextisland, size=filledSize })
    nextisland = self:findIsland(cp)
  end

  return list

end

--- Find an cell in a map that is falsy.
-- Returns nil if none are found.
function module:findHole(a)

  local width, height = #a, #a[1]
  for x=1, width do
    for y=1, height do
      if a[x][y] == 0 then
        return { x=x, y=y }
      end
    end
  end

end

--- Find a cell in a map that is truthy.
function module:findIsland(a)

  local width, height = #a, #a[1]
  for x=1, width do
    for y=1, height do
      if a[x][y] > 0 then
        return { x=x, y=y, value=a[x][y] }
      end
    end
  end

end

--- Flood fill. Returns the size of the filled area.
function module:floodFill(a, x, y, oldvalue, newvalue)

  local width, height = #a, #a[1]
  local filledSize = 0
  local stack = {}

  -- add the first point to check
  table.insert(stack, {x=x, y=y} )

  while #stack > 0 do
    -- get stack point
    local point = table.remove(stack)
    -- fill this point
    a[point.x][point.y] = newvalue
    filledSize = filledSize + 1
    -- test if we need to add neighbours to the stack
    local offsets = { {0,-1}, {1,0}, {0,1}, {-1,0} }
    for _, offset in ipairs(offsets) do
      local px = point.x + offset[1]
      local py = point.y + offset[2]
      -- within bounds
      if px > 0 and py > 0 and px <= width and py <= height then
        -- if the neighbour is falsy
        if a[px][py] == oldvalue then
          -- add it to the stack of points to check
          table.insert(stack, {x=px, y=py} )
        end
      end
    end

  end

  return filledSize

end

--- Sets all cells in an array falsy where they are also falsy on a contour map.
function module:clipIncludeContour(a, contour)
  local width, height = #contour, #contour[1]

  for x=1, width do
    for y=1, height do
      if contour[x][y] == 0 then
        a[x][y] = 0
      end
    end
  end

end

--- Opposite of clipIncludeContour
function module:clipExcludeContour(a, contour)
  local width, height = #contour, #contour[1]

  for x=1, width do
    for y=1, height do
      if contour[x][y] > 0 then
        a[x][y] = 0
      end
    end
  end

end

--- Find a random position on the coastline.
-- The found point will be on the water next to land.
--
-- @tparam table a
-- Array to search.
--
-- @tparam number seed
--
-- @tparam[opt] function startTest
-- Function(value) that must return true to find the starting point on the map.
--
-- @tparam[opt] function endTest
-- Function(value) that must return true to end the search
--
-- @treturn CoastlineResult
function module:findCoastline(a, seed, startTest, endTest)

  -- use default provided test functions
  startTest = startTest or function(value) return value == 0 end
  endTest = endTest or function(value) return value > 0 end

  seed = seed or os.time()
  math.randomseed(seed)

  local width, height = #a, #a[1]

  -- find a random open point on the contour
  local x, y = 0, 0
  repeat
    x = math.random(2, width-1)
    y = math.random(2, height-1)
  until startTest(a[x][y])

  -- find the shoreline in a random direction
  local ox, oy = 0, 0

  -- move either up/down or left/right
  repeat
    ox, oy = math.random(-1, 1), math.random(-1, 1)
  until (ox == 0 and oy ~= 0) or (ox ~= 0 and oy == 0)

  -- move in direction until we hit land
  while not endTest(a[x+ox][y+oy]) do
    x = x + ox
    y = y + oy
  end

  --- Costline find result
  -- @table CoastlineResult
  -- @tfield number x
  -- @tfield number y
  -- @tfield boolean horizontal
  -- @tfield boolean vertical

  return {
    x=x,
    y=y,
    horizontal=ox ~= 0,
    vertical=oy ~= 0
  }

end

return module
