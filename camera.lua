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
    frameWidth = love.graphics.getWidth( ),
    frameHeight = love.graphics.getHeight( ),
    frameTop = 0,
    frameLeft = 0,
    
    worldWidth = love.graphics.getWidth( ),
    worldHeight = love.graphics.getHeight( ),
    
}

local lume = require("lume")

function module:update(dt)
    
    if (self.x ~= self.targetX) or (self.y ~= self.targetY) then
        self.frames = self.frames + dt
        
        -- move the camera
        self.x = lume.lerp(self.fromX, self.targetX, self.frames)
        self.y = lume.lerp(self.fromY, self.targetY, self.frames)
        
        -- clamp to the world
        self.x = lume.clamp(self.x, - self.worldWidth + self.frameWidth, 0 )
        self.y = lume.clamp(self.y, - self.worldHeight + self.frameHeight, 0 )
        
    end
    
end

function module:worldSize(width, height)
    
    self.worldWidth = width
    self.worldHeight = height
    
end

function module:frame(left, top, width, height)
    
    self.frameLeft = left
    self.frameTop = top
    self.frameWidth = width
    self.frameHeight = height
    
end

function module:lookAt(x, y)
    
    --print("looking at",x,y,self.targetX,self.targetY, self.frames)
    if self.targetX ~= x or self.targetY ~= y then
        self.frames = 0
        self.fromX = self.x
        self.fromY = self.y
        self.targetX = x
        self.targetY = y
    end
    
end

function module:moveBy(dx, dy)
   
   self:lookAt(self.targetX + dx, self.targetY + dy)
    
end

function module:center(x, y)
   
    local dx = - x + (self.frameWidth / 2)
    local dy = - y + (self.frameHeight / 2)
    self:lookAt(dx, dy)
    
end

function module:pose()
    
    love.graphics.push()
    love.graphics.translate(self.x + self.frameLeft, self.y + self.frameTop)
    
end

function module:relax()
    
    love.graphics.pop()
    
end

return module