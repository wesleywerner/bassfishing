--[[
   camera.lua

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

local module = {
    frames = 0,
    targetX = 0,
    targetY = 0,
    x = 0,
    y = 0,
    width = love.graphics.getWidth( ),
    height = love.graphics.getHeight( ),
    top = 0,
    left = 0
}

local function clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

local function lerp(a, b, amount)
  return a + (b - a) * clamp(amount, 0, 1)
end

function module:update(dt)
    
    if self.frames < 1 then
        self.frames = self.frames + dt / 3
        self.x = lerp(self.x, self.targetX, self.frames)
        self.y = lerp(self.y, self.targetY, self.frames)
    end
    
end

function module:frame(top, left, width, height)
    
    self.top = top
    self.left = left
    self.width = width
    self.height = height
    
end

function module:lookAt(x, y)
    
    if self.targetX ~= x or self.targetY ~= y then
        self.frames = 0
        self.targetX = x
        self.targetY = y
    end
    
end

function module:moveBy(dx, dy)
   
    self.frames = 0
    self.targetX = self.targetX + dx
    self.targetY = self.targetY + dy
    
end

function module:center(x, y)
   
    local dx = - x + self.left + (self.width / 2)
    local dy = - y + self.top + (self.height / 2)
    self:lookAt(dx, dy)
    
end

function module:pose()
    
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
end

function module:relax()
    
    love.graphics.pop()
    
end

return module