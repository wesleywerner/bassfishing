--[[
   tiles.lua

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

local tiles = {}

-- the distance in meters a tile represents
tiles.inmeters = 6
tiles.size = 16
tiles.center = tiles.size / 2
tiles.image = love.graphics.newImage("res/tiles.png")
tiles.w, tiles.h = tiles.image:getDimensions()

-- use sharp interpolation
tiles.image:setFilter("nearest", "nearest", 1)

tiles.water = love.graphics.newQuad(80, 16, 16, 16, tiles.w, tiles.h)

-- alcoves provide a rounded tile for single tiled dead-ends
tiles.alcove = { }
tiles.alcove.left = love.graphics.newQuad(16, 80, 16, 16, tiles.w, tiles.h)
tiles.alcove.right = love.graphics.newQuad(32, 80, 16, 16, tiles.w, tiles.h)
tiles.alcove.top = love.graphics.newQuad(16, 96, 16, 16, tiles.w, tiles.h)
tiles.alcove.bottom = love.graphics.newQuad(16, 112, 16, 16, tiles.w, tiles.h)

tiles.land = { }
tiles.land.open = love.graphics.newQuad(32, 32, 16, 16, tiles.w, tiles.h)

-- land corners provide rounded edges
tiles.land.corner = { }
tiles.land.corner.topleft = love.graphics.newQuad(16, 16, 16, 16, tiles.w, tiles.h)
tiles.land.corner.topright = love.graphics.newQuad(48, 16, 16, 16, tiles.w, tiles.h)
tiles.land.corner.bottomleft = love.graphics.newQuad(16, 48, 16, 16, tiles.w, tiles.h)
tiles.land.corner.bottomright = love.graphics.newQuad(48, 48, 16, 16, tiles.w, tiles.h)

-- land points
tiles.land.point = { }
tiles.land.point.left = love.graphics.newQuad(16, 32, 16, 16, tiles.w, tiles.h)
tiles.land.point.right = love.graphics.newQuad(48, 32, 16, 16, tiles.w, tiles.h)
tiles.land.point.top = love.graphics.newQuad(32, 16, 16, 16, tiles.w, tiles.h)
tiles.land.point.bottom = love.graphics.newQuad(32, 48, 16, 16, tiles.w, tiles.h)

--tiles.land.corner.top = love.graphics.newQuad(48, 32, 16, 16, tiles.w, tiles.h)
--tiles.land.corner.right = love.graphics.newQuad(16, 32, 16, 16, tiles.w, tiles.h)
--tiles.land.corner.top = love.graphics.newQuad(32, 48, 16, 16, tiles.w, tiles.h)
--tiles.land.corner.bottom = love.graphics.newQuad(32, 16, 16, 16, tiles.w, tiles.h)

-- land insets provide small corners that join land tiles together
tiles.land.inset = { }
tiles.land.inset.topleft = love.graphics.newQuad(80, 48, 16, 16, tiles.w, tiles.h)
tiles.land.inset.topright = love.graphics.newQuad(96, 48, 16, 16, tiles.w, tiles.h)
tiles.land.inset.bottomleft = love.graphics.newQuad(80, 64, 16, 16, tiles.w, tiles.h)
tiles.land.inset.bottomright = love.graphics.newQuad(96, 64, 16, 16, tiles.w, tiles.h)


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
  love.graphics.newQuad(336, 48, 16, 16, tiles.w, tiles.h),
}

tiles.obstacles.logs = {
  love.graphics.newQuad(288, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(304, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(320, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(336, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(352, 64, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(368, 64, 16, 16, tiles.w, tiles.h),
}

tiles.boats = {
  love.graphics.newQuad(384, 48, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(400, 48, 16, 16, tiles.w, tiles.h),
  love.graphics.newQuad(416, 48, 16, 16, tiles.w, tiles.h),
}

tiles.fish = { }
tiles.fish.home = love.graphics.newQuad(384, 96, 16, 16, tiles.w, tiles.h)
tiles.fish.feed = love.graphics.newQuad(400, 96, 16, 16, tiles.w, tiles.h)

tiles.fish.small = love.graphics.newQuad(432, 96, 16, 16, tiles.w, tiles.h)
tiles.fish.medium = love.graphics.newQuad(448, 96, 22, 22, tiles.w, tiles.h)
tiles.fish.large = love.graphics.newQuad(470, 96, 32, 32, tiles.w, tiles.h)

tiles.dockpointer = love.graphics.newQuad(80, 144, 16, 16, tiles.w, tiles.h)

return tiles
