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
tiles.image = love.graphics.newImage("res/tiles.png")
tiles.w, tiles.h = tiles.image:getDimensions()
tiles.water = love.graphics.newQuad(128, 148, 16, 16, tiles.w, tiles.h)
tiles.land = love.graphics.newQuad(96, 28, 16, 16, tiles.w, tiles.h)
tiles.plants = {
  love.graphics.newQuad(160, 148, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(193, 148, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(225, 148, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(256, 148, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(289, 148, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(321, 148, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(288, 228, 16, 16, tiles.w, tiles.h),
}
tiles.trees = {
  love.graphics.newQuad(384, 108, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(416, 108, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(448, 108, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(480, 108, 16, 16, tiles.w, tiles.h),
}
tiles.buildings = {
  love.graphics.newQuad(288, 108, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(320, 108, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(352, 108, 16, 16, tiles.w, tiles.h),
}
tiles.jetty = love.graphics.newQuad(448, 188, 16, 16, tiles.w, tiles.h)

local legend = {
  ["Land"] = {92, 64, 32},
  ["Water"] = {16, 16, 64},
  ["Aquatic Plant"] = {16, 40, 56},
  ["Tree"] = {32, 92, 32},
  ["Building"] = {192, 192, 64},
  ["Jetty"] = {128, 128, 128}
}

local drawmode = "fancy"
local drawoffset = {x=0, y=0}
local mapstep = 16 * 3


function love.load()

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
    love.graphics.scale(1.5, 1.5)
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

      local ground = lake.contour[x][y]

      love.graphics.setColor(255, 255, 255)

      if ground then
        love.graphics.draw(tiles.image, tiles.land, x*16, y*16)
      else
        -- draw lake depth
        --local shallow = lake.depth[x][y]
        --if shallow then
          ---- change the plant draw
          --if math.random() < 0.1 then
            --plantid = math.random(1, #tiles.plants)
          --end
          --love.graphics.draw(tiles.image, tiles.plants[plantid], x*16, y*16)
        --else
          --love.graphics.draw(tiles.image, tiles.water, x*16, y*16)
        --end
        love.graphics.draw(tiles.image, tiles.water, x*16, y*16)
      end

      local plantid = lake.plants[x][y]
      if plantid > 0 then
        local plantidx = math.max(1, plantid % #tiles.plants)
        love.graphics.draw(tiles.image, tiles.plants[plantidx], x*16, y*16)
      end

      local tree = lake.trees[x][y]
      if tree then
        local id = math.random(1, #tiles.trees)
        love.graphics.draw(tiles.image, tiles.trees[id], x*16, y*16)
      end

      local house = lake.buildings[x][y]
      if house then
        local id = math.random(1, #tiles.buildings)
        love.graphics.draw(tiles.image, tiles.buildings[id], x*16, y*16)
      end

      local jetty = lake.jetties[x][y]
      if jetty then
        love.graphics.draw(tiles.image, tiles.jetty, x*16, y*16)
      end

    end
  end

  love.graphics.setCanvas()

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

      local ground = lake.contour[x][y]

      if ground then
        love.graphics.setColor(legend["Land"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      else
        -- draw lake depth
        local shallow = lake.depth[x][y]
        if shallow then
          love.graphics.setColor(legend["Aquatic Plant"])
        else
          love.graphics.setColor(legend["Water"])
        end
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local tree = lake.trees[x][y]
      if tree then
        love.graphics.setColor(legend["Tree"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local house = lake.buildings[x][y]
      if house then
        love.graphics.setColor(legend["Building"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local jetty = lake.jetties[x][y]
      if jetty then
        love.graphics.setColor(legend["Jetty"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

    end
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
