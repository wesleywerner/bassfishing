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

    -- a value 0..1 indicating progress of the camera start..end position
    frames = 0,

    -- the time in seconds the movement should take
    time = 1,

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
        self.frames = self.frames + (dt / self.time)

        -- move the camera
        self.x = lume.lerp(self.fromX, self.targetX, self.frames)
        self.y = lume.lerp(self.fromY, self.targetY, self.frames)

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

    -- we only update the movement if the target is new
    if self.targetX ~= x or self.targetY ~= y then
        self.frames = 0
        self.fromX = self.x
        self.fromY = self.y

        -- clamp to the world
        self.targetX = lume.clamp(x, - self.worldWidth + self.frameWidth, 0 )
        self.targetY = lume.clamp(y, - self.worldHeight + self.frameHeight, 0 )

        -- the time taken to move the camera is a function of distance over the smallest world side.
        -- this means smaller movements happen slower.
        local dist = lume.distance(self.x, self.y, x, y, false) / math.min( self.worldHeight, self.worldWidth )
        dist = math.exp(dist)
        -- limit the time to sane values
        self.time = lume.clamp(dist, 0.5, 6)
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
    love.graphics.setScissor( self.frameLeft, self.frameTop, self.frameWidth, self.frameHeight )

end

function module:relax()

    love.graphics.setScissor()
    love.graphics.pop()

end

function module:pointToFrame(x, y)

    if x < self.frameLeft or x > self.frameLeft + self.frameWidth then
        return nil
    end

    if y < self.frameTop or y > self.frameTop + self.frameHeight then
        return nil
    end

    return lume.clamp(x - self.x - self.frameLeft, 0, self.worldWidth),
        lume.clamp(y - self.y - self.frameTop, 0, self.worldHeight)

end

return module
