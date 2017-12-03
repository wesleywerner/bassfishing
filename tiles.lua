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

tiles.size = 16
tiles.center = tiles.size / 2
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

tiles.land = love.graphics.newQuad(32, 32, 16, 16, tiles.w, tiles.h)

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
  love.graphics.newQuad(416, 48, 16, 16, tiles.w, tiles.h),
}

tiles.fish = { }
tiles.fish.home = love.graphics.newQuad(384, 96, 16, 16, tiles.w, tiles.h)
tiles.fish.feed = love.graphics.newQuad(400, 96, 16, 16, tiles.w, tiles.h)

return tiles
