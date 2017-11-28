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
    
    -- camera goal on screen
    targetX = 0,
    targetY = 0,
    
    -- camera actual on screen
    x = 0,
    y = 0,
    
    -- camera frame size and position
    width = love.graphics.getWidth( ),
    height = love.graphics.getHeight( ),
    top = 0,
    left = 0,
    
}

local function clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

local function lerp(a, b, amount)
  return a + (b - a) * clamp(amount, 0, 1)
end

function module:update(dt)
    
    if self.frames <= 1 then
        self.frames = self.frames + dt * 0.01
        
        -- move the camera
        self.x = lerp(self.x, self.targetX, self.frames)
        self.y = lerp(self.y, self.targetY, self.frames)
        
        -- clamp top left
        self.x = math.min(0, self.x )
        self.y = math.min(0, self.y )
        
        -- clamp bottom right
        --self.x = 
        --self.y = 
        
    end
    
end

function module:frame(left, top, width, height)
    
    self.left = left
    self.top = top
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
   
   self:lookAt(self.targetX + dx, self.targetY + dy)
    
end

function module:center(x, y)
   
    local dx = - x + (self.width / 2)
    local dy = - y + (self.height / 2)
    self:lookAt(dx, dy)
    
end

function module:pose()
    
    love.graphics.push()
    love.graphics.translate(self.x + self.left, self.y + self.top)
    
end

function module:relax()
    
    love.graphics.pop()
    
end

return module