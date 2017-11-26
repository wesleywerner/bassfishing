--[[
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

Attempting to generate top-down 2D terrain using noise and cellular automata.

]]--

local helptext = [[Welcome to the lake generator demo!
"up"/"down": adjust cellular automata iterations
"left"/"right": change the seed
"ins"/"del": increase/decrease the noise density
"space": toggle render mode
WSAD keys moves around in render mode]]

local genie = require("lakegenerator")
local lake = nil

-- Define the tile images
local tiles = {}
tiles.image = love.graphics.newImage("res/newtiles.png")
tiles.w, tiles.h = tiles.image:getDimensions()

tiles.water = {}
tiles.water.open = love.graphics.newQuad(80, 16, 16, 16, tiles.w, tiles.h)
tiles.water.left = love.graphics.newQuad(48, 32, 16, 16, tiles.w, tiles.h)
tiles.water.right = love.graphics.newQuad(16, 32, 16, 16, tiles.w, tiles.h)
tiles.water.top = love.graphics.newQuad(32, 48, 16, 16, tiles.w, tiles.h)
tiles.water.bottom = love.graphics.newQuad(32, 16, 16, 16, tiles.w, tiles.h)
tiles.water.topleft = love.graphics.newQuad(80, 48, 16, 16, tiles.w, tiles.h)
tiles.water.topright = love.graphics.newQuad(96, 48, 16, 16, tiles.w, tiles.h)
tiles.water.bottomleft = love.graphics.newQuad(80, 64, 16, 16, tiles.w, tiles.h)
tiles.water.bottomright = love.graphics.newQuad(96, 64, 16, 16, tiles.w, tiles.h)
tiles.water.leftalcove = love.graphics.newQuad(16, 80, 16, 16, tiles.w, tiles.h)
tiles.water.rightalcove = love.graphics.newQuad(32, 80, 16, 16, tiles.w, tiles.h)
tiles.water.topalcove = love.graphics.newQuad(16, 96, 16, 16, tiles.w, tiles.h)
tiles.water.bottomalcove = love.graphics.newQuad(16, 112, 16, 16, tiles.w, tiles.h)

tiles.land = {}
tiles.land.flat = love.graphics.newQuad(32, 32, 16, 16, tiles.w, tiles.h)

tiles.plants = {
  love.graphics.newQuad(208, 16, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(240, 16, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(272, 16, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(304, 16, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(336, 16, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(368, 16, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(400, 16, 16, 16, tiles.w, tiles.h),
}
tiles.trees = {
  love.graphics.newQuad(208, 96, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(240, 96, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(272, 96, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(304, 96, 16, 16, tiles.w, tiles.h),
}
tiles.buildings = {
  love.graphics.newQuad(208, 144, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(240, 144, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(272, 144, 16, 16, tiles.w, tiles.h),
}
tiles.jetties = {}
tiles.jetties.horizontal = love.graphics.newQuad(256, 48, 16, 16, tiles.w, tiles.h)
tiles.jetties.vertical = love.graphics.newQuad(224, 48, 16, 16, tiles.w, tiles.h)

tiles.obstacles = {}
tiles.obstacles.rocks = {
  love.graphics.newQuad(288, 48, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(304, 48, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(320, 48, 16, 16, tiles.w, tiles.h),
}
tiles.obstacles.logs = {
  love.graphics.newQuad(288, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(304, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(320, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(336, 64, 16, 16, tiles.w, tiles.h),
}
tiles.boats = {
  love.graphics.newQuad(384, 48, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(400, 48, 16, 16, tiles.w, tiles.h),
}

local legend = {
  ["Land"] = {92, 64, 32},
  ["Water"] = {16, 16, 64},
  ["Aquatic Plant"] = {16, 40, 56},
  ["Tree"] = {32, 92, 32},
  ["Building"] = {192, 192, 64},
  ["Jetty"] = {128, 128, 128},
  ["Obstacle"] = {128, 64, 64}
}

local drawmode = "legend"   -- legend/fancy
local drawoffset = {x=0, y=0}
local mapstep = 16 * 3


function love.load()

  love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
  lake = genie:generate(80, 30, 0, 0.25, 6)

end

function love.update(dt)

end

function love.draw()

  if drawmode == "legend" then
    drawWithLegend()
  elseif drawmode == "fancy" then
    if tiles.rendered == nil then renderLakeToImage() end
    love.graphics.setColor(255, 255, 255)
    --love.graphics.scale(2, 2)
    love.graphics.draw(tiles.rendered, drawoffset.x, drawoffset.y)
  end

end

function renderLakeToImage()

  local tilesize = 16

  tiles.rendered = nil
  tiles.rendered = love.graphics.newCanvas( (lake.width+1)*tilesize, (lake.height+1)*tilesize )

  love.graphics.setCanvas(tiles.rendered)

  for x=1, lake.width do
    for y=1, lake.height do

      local ground = lake.contour[x][y] > 0

      love.graphics.setColor(255, 255, 255)

      if ground then
        love.graphics.draw(tiles.image, tiles.land.flat, x*16, y*16)
      else
        -- draw open water tile
        love.graphics.draw(tiles.image, tiles.water.open, x*16, y*16)
        -- and any special corner tile
        local waterquad = getWaterCorner(lake.contour, x, y)
        love.graphics.draw(tiles.image, waterquad, x*16, y*16)
      end

      local plantid = lake.plants[x][y]
      if plantid > 0 then
        local plantidx = math.max(1, plantid % #tiles.plants)
        love.graphics.draw(tiles.image, tiles.plants[plantidx], x*16, y*16)
      end

      local treeid = lake.trees[x][y]
      if treeid > 0 then
        local treeidx = math.max(1, treeid % #tiles.trees)
        love.graphics.draw(tiles.image, tiles.trees[treeidx], x*16, y*16)
      end

      local house = lake.buildings[x][y] > 0
      if house then
        local id = math.random(1, #tiles.buildings)
        love.graphics.draw(tiles.image, tiles.buildings[id], x*16, y*16)
      end

    end
  end

  -- Draw jetties
  for _, jetty in ipairs(lake.jetties) do
    if jetty.horizontal then
      love.graphics.draw(tiles.image, tiles.jetties.horizontal, jetty.x*16, jetty.y*16)
    else
      love.graphics.draw(tiles.image, tiles.jetties.vertical, jetty.x*16, jetty.y*16)
    end
  end

  -- Draw obstacles
  for _, obs in ipairs(lake.obstacles) do
    if obs.log then
      local id = math.random(1, #tiles.obstacles.logs)
      love.graphics.draw(tiles.image, tiles.obstacles.logs[id], obs.x*16, obs.y*16)
    elseif obs.rock then
      local id = math.random(1, #tiles.obstacles.rocks)
      love.graphics.draw(tiles.image, tiles.obstacles.rocks[id], obs.x*16, obs.y*16)
    elseif obs.boat then
      local id = math.random(1, #tiles.boats)
      love.graphics.draw(tiles.image, tiles.boats[id], obs.x*16, obs.y*16)
    end
  end

  love.graphics.setCanvas()

end


--- Get the quad to draw a corner of water as interpolated by the land around it.
function getWaterCorner(a, x, y)

  local leftX = math.max(1, x-1)
  local rightX = math.min(#a, x+1)
  local topY = math.max(1, y-1)
  local bottomY = math.min(#a[1], y+1)

  local left = a[leftX][y] > 0
  local top = a[x][topY] > 0
  local right = a[rightX][y] > 0
  local bottom = a[x][bottomY] > 0

  if top and bottom and left and not right then
    return tiles.water.leftalcove
  elseif top and bottom and right and not left then
    return tiles.water.rightalcove
  elseif left and right and top and not bottom then
    return tiles.water.topalcove
  elseif left and right and bottom and not top then
    return tiles.water.bottomalcove
  elseif top and left then
    return tiles.water.topleft
  elseif top and right then
    return tiles.water.topright
  elseif bottom and left then
    return tiles.water.bottomleft
  elseif bottom and right then
    return tiles.water.bottomright
  elseif left then
    return tiles.water.left
  elseif right then
    return tiles.water.right
  elseif top then
    return tiles.water.top
  elseif bottom then
    return tiles.water.bottom
  else
    return tiles.water.open
  end

end


function drawWithLegend()

  -- print help
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(helptext, 10, 10, 600)
  love.graphics.print(string.format("seed: %d\ndensity: %f\niter: %s", lake.seed, lake.density, lake.iterations), 650, 10)

  -- draw legend
  local legendx = 500
  local legendy = 10
  for key, color in pairs(legend) do
    love.graphics.setColor({200, 200, 200})
    love.graphics.print(key, legendx+20, legendy)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", legendx, legendy, 10, 10)
    legendy = legendy + 20
  end

  -- scale the map to fit
  love.graphics.translate(0, 200)
  love.graphics.scale(8, 8)

  for x=1, lake.width do
    for y=1, lake.height do

      local ground = lake.contour[x][y] > 0

      if ground then
        love.graphics.setColor(legend["Land"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      else
        -- draw lake depth
        local shallow = lake.depth[x][y] > 0
        if shallow then
          love.graphics.setColor(legend["Aquatic Plant"])
        else
          love.graphics.setColor(legend["Water"])
        end
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local tree = lake.trees[x][y] > 0
      if tree then
        love.graphics.setColor(legend["Tree"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local house = lake.buildings[x][y] > 0
      if house then
        love.graphics.setColor(legend["Building"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

    end
  end

  -- Draw jetties
  love.graphics.setColor(legend["Jetty"])
  for _, jetty in ipairs(lake.jetties) do
    love.graphics.rectangle("fill", jetty.x, jetty.y, 1, 1)
  end

  -- Draw obstacles
  love.graphics.setColor(legend["Obstacle"])
  for _, jetty in ipairs(lake.obstacles) do
    love.graphics.rectangle("fill", jetty.x, jetty.y, 1, 1)
  end

end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "left" then
    lake = genie:generate(
      lake.width, lake.height, math.max(0, lake.seed - 1), lake.density, lake.iterations)
    tiles.rendered = nil
  elseif key == "right" then
    lake = genie:generate(
      lake.width, lake.height, math.max(0, lake.seed + 1), lake.density, lake.iterations)
    tiles.rendered = nil
  elseif key == "up" then
    lake = genie:generate(
      lake.width, lake.height, lake.seed, lake.density, math.max(0, lake.iterations + 1))
    tiles.rendered = nil
  elseif key == "down" then
    lake = genie:generate(
      lake.width, lake.height, lake.seed, lake.density, math.max(0, lake.iterations - 1))
    tiles.rendered = nil
  elseif key == "insert" then
    lake = genie:generate(
      lake.width, lake.height, lake.seed, math.max(0, lake.density + .025), lake.iterations)
    tiles.rendered = nil
  elseif key == "delete" then
    lake = genie:generate(
      lake.width, lake.height, lake.seed, math.max(0, lake.density - .025), lake.iterations)
    tiles.rendered = nil
  elseif key == "kp-" then
    lake = genie:generate(
      lake.width, math.max(30, lake.height - 1), lake.seed, lake.density, lake.iterations)
    tiles.rendered = nil
  elseif key == "kp+" then
    lake = genie:generate(
      lake.width, math.min(80, lake.height + 1), lake.seed, lake.density, lake.iterations)
    tiles.rendered = nil
  end

  if key == "space" then
    if drawmode == "fancy" then
      drawmode = "legend"
    else
      drawmode = "fancy"
    end
  end

  -- fancy map movement
  if key == "w" then
    drawoffset.y = math.min(0, drawoffset.y + mapstep)
  elseif key == "s" then
    drawoffset.y = drawoffset.y - mapstep
  elseif key == "a" then
    drawoffset.x = math.min(0, drawoffset.x + mapstep)
  elseif key == "d" then
    drawoffset.x = drawoffset.x - mapstep
  end

end
