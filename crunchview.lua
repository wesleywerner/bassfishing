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

local module = {}
local states = require("states")
local lume = require("lume")


function module:init(data)
    
    -- expect data to contain info on what we crunched

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    self.shaking = 60
    self.width = love.graphics.getWidth()
    
    love.graphics.setFont( love.graphics.newFont( 60 ) )

end

function module:keypressed(key)
    
    if self.shaking < 1 then
        states:pop()
    end
    
end

function module:update(dt)

    self.shaking = lume.lerp(self.shaking, 0, 7*dt)

end

function module:draw()
    
    -- shake effect
    love.graphics.push()
    if self.shaking > 1 then
        love.graphics.translate((math.random()-.5) * self.shaking, (math.random()-.5) * self.shaking)
    end
    
    -- underlay screenshot
    love.graphics.draw(self.screenshot)

    love.graphics.setColor(255, 255, 255)
    love.graphics.printf("CRUNCH!!!!", 0, 0, self.width, "center")
    
    love.graphics.pop()

end

return module
