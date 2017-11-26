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

References:

  Excellent noise generation page:
  http://lodev.org/cgtutor/randomnoise.html

  Nice tutorial implementing cellular automata:
  https://gamedevelopment.tutsplus.com/tutorials/generate-random-cave-levels-using-cellular-automata--gamedev-9664

  Good old rogue basin for cave generation:  http://www.roguebasin.com/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels

]]--

local module = {}

--- Returns an empty 2D array of width and height.
function module:array(width, height, default)

  local a = {}
  default = default or false

  for x=1, width do
    a[x] = {}
    for y=1, height do
      a[x][y] = default
    end
  end

  return a

end

-- Fills an array with noise.
function module:noise(a, seed)

  seed = seed or os.time()
  math.randomseed(seed)

  local width = #a
  local height = #a[1]

  for x=1, width do
    for y=1, height do
      a[x][y] = math.random()
    end
  end

end

--- Populate an array with random bits weighed towards density (0..1)
function module:populate(a, seed, density)

  seed = seed or os.time()
  math.randomseed(seed)

  local width = #a
  local height = #a[1]

  for x=1, width do
    for y=1, height do
      if math.random() < density then
        a[x][y] = true
      else
        a[x][y] = false
      end
    end
  end

end

-- Place random blocks in the array
function module:populateBlocks(a, seed, density)

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
        a[x][y] = true

      end
    end
  end

end

--- Count living neighbouring cells in an array.
function module:countNeighbours(a, px, py)

  local width = #a
  local height = #a[1]

  local count = 0
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
        elseif a[nx][ny] then
          -- count if this neighbour is positive
          count = count + 1
        end
      end
    end
  end
  return count

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
        local alive = a[x][y]
        -- copy the cell
        b[x][y] = alive
        -- count neighbours at this point
        local neighbours = self:countNeighbours(a, x, y)
        -- alone cells die off without enough neighbours
        if alive and neighbours < deathLimit then
          -- the cell dies
          b[x][y] = false
        elseif not alive and neighbours > birthLimit then
          -- a new cell is born
          b[x][y] = true
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
    a[x][1] = true
    a[x][height] = true
  end
  for y=1, height do
    a[1][y] = true
    a[width][y] = true
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

  --local width, height = #a, #a[1]

  ---- make a list of all the holes in the map and their size.
  ---- we use a copy of the map for this, as it will destroy the map.
  --local cp = self:copy(a)
  --local holes = {}
  --local nexthole = self:findHole(cp)

  --while nexthole ~= nil do
    --local filledSize = self:floodFill(cp, nexthole.x, nexthole.y)
    --table.insert(holes, { pos=nexthole, size=filledSize })
    --nexthole = self:findHole(cp)
  --end

  local holes = self:getListOfHoles(a)

  -- sort the list, smallest hole first
  table.sort(holes, function(a, b)
    return a.size < b.size
  end)

  -- remove the largest hole from the list
  table.remove(holes)

  -- fill the remaining holes on the original array
  for _, hole in ipairs(holes) do
    self:floodFill(a, hole.pos.x, hole.pos.y, false, true)
  end

end

--- Assign a number to each island in a map.
function module:numberRegions(a)

  local regions = self:getListOfIslands(a)
  for i, reg in ipairs(regions) do
    self:floodFill(a, reg.pos.x, reg.pos.y, true, i)
  end

  -- as a courtesy we zero out the rest
  local width, height = #a, #a[1]
  for x=1, width do
    for y=1, height do
      if type(a[x][y]) == "boolean" then
        a[x][y] = 0
      end
    end
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
    local filledSize = self:floodFill(cp, nexthole.x, nexthole.y, false, true)
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
    local filledSize = self:floodFill(cp, nextisland.x, nextisland.y, true, false)
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
      if not a[x][y] then
        return {x=x, y=y}
      end
    end
  end

end

--- Find a cell in a map that is truthy.
function module:findIsland(a)

  local width, height = #a, #a[1]
  for x=1, width do
    for y=1, height do
      if a[x][y] then
        return {x=x, y=y}
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
      if not contour[x][y] then
        a[x][y] = false
      end
    end
  end

end

--- Opposite of clipIncludeContour
function module:clipExcludeContour(a, contour)
  local width, height = #contour, #contour[1]

  for x=1, width do
    for y=1, height do
      if contour[x][y] then
        a[x][y] = false
      end
    end
  end

end

--- Place jetties on a map conforming to a contour.
function module:placeJetties(a, contour, seed, density)

  seed = seed or os.time()
  math.randomseed(seed)

  local width, height = #contour, #contour[1]
  local amount = width * height * density

  while amount > 0 do

    -- find a random open point on the contour
    local x, y = 1, 1
    while contour[x][y] do
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
    while not contour[x+offsetx][y] do
      x = x + offsetx
    end

    -- this spot is a jetty
    a[x][y] = true
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
  data.contour = self:array(width, height)
  -- add random noise to start our contours
  self:populate(data.contour, seed, density)
  -- add variety by placing some random land masses (or plain blocks if you prefer)
  self:populateBlocks(data.contour, seed, density)
  -- close off the map with a border
  self:addBorder(data.contour)
  -- put it through cellular evolution
  self:cellulate(data.contour, iterations)
  -- fill in the gaps
  self:fillHoles(data.contour)

  -- generate the water depth: a 2D boolean array where shallow is "true".
  -- reduce evolution iterations to make it more "ragged".
  -- (psst: it is a contour map with a higher density)
  data.depth = self:array(width, height)
  self:populate(data.depth, seed, density + 0.1)
  self:populateBlocks(data.depth, seed, density - 0.1)
  self:cellulate(data.depth, math.floor(iterations / 3))

  -- generate aquatic plants
  -- (we reuse the depth map, the idea being plants grow in shallow waters)
  data.plants = self:copy(data.depth)
  self:clipExcludeContour(data.plants, data.contour)
  self:numberRegions(data.plants)

  -- generate trees (cellular evolution around the contour)
  data.trees = self:array(width, height)
  self:populate(data.trees, seed, 0.45) -- n% of the surface
  self:cellulate(data.trees, 6)
  self:clipIncludeContour(data.trees, data.contour)

  -- generate buildings (dotted around the contour)
  data.buildings = self:array(width, height)
  self:populate(data.buildings, seed, 0.01)  -- n% of the surface
  self:clipIncludeContour(data.buildings, data.contour)

  -- place jetties
  data.jetties = self:array(width, height)
  self:placeJetties(data.jetties, data.contour, seed, 0.002)  -- n% of the surface

  return data

end

return module
