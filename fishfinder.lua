--[[
   fishfinder.lua

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
    -- number of data points to keep in history
    history = 8,
    -- data points
    points = {},
    -- true when rendering to canvas is required
    refresh = true,
    -- size and position
    top = 0,
    left = 0,
    width = 200,
    height = 200
}
local glob = require("globals")
local player = require("player")

function module:update()
    
    local depth = glob.lake.depth[player.x][player.y]
    
    -- Fill the points list if empty
    if #self.points == 0 then
        for n=1, self.history do
            table.insert(self.points, {
                depth = depth,
                fish = 0
            })
        end
    else
        table.insert(self.points, {
            depth = depth,
            fish = math.random(0, 1)
        })
    end
    
    -- remove old
    while #self.points > self.history do
       table.remove(self.points, 1) 
    end
    
    self.refresh = true
    
end

function module:draw()
    
    -- render to canvas
    if self.refresh then
        
        love.graphics.push()
        local backgroundcolor = { 140, 185, 164 }
        local foregroundcolor = { 0, 85, 182, 128 }
        
        self.image = nil
        self.image = love.graphics.newCanvas( self.width, self.height )
        love.graphics.setCanvas(self.image)
        
        -- background
        love.graphics.setColor(backgroundcolor)
        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        
        -- border
        love.graphics.setLineWidth( 6 )
        love.graphics.setColor(foregroundcolor)
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
        love.graphics.setLineWidth( 1 )
        
        -- draw land
        if #self.points > 3 then
            
            -- build the list of depth vertices
            local vertices = { 0, self.height + 1 } -- ensure start point is an extremity
            
            for n, point in ipairs(self.points) do
                
                -- history moves from right to left
                local px = ( self.width / (self.history-1) ) * (n-1)
                
                -- depth 0=bottom 1=surface
                local py = self.height - ( self.height * point.depth )
                table.insert(vertices, px)
                table.insert(vertices, py)
                
                -- draw a fish
                if point.fish > 0 then
                    love.graphics.print("^", px, py - 20)
                end
                
            end
            
            -- insert a bottom-left vertice at no 1, and bottom-right vertice at last position.
            -- this completes a polygon
            table.insert(vertices, self.width)
            table.insert(vertices, self.height + 1) -- ensure end point is an extremity

            love.graphics.setColor(foregroundcolor)
            love.graphics.setLineJoin("none")
            local triangles = love.math.triangulate ( vertices )
            for triNo, triangle in ipairs ( triangles ) do
                love.graphics.polygon ( "fill", triangle )
            end
        
        end
        
        love.graphics.setCanvas()
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth( 1 )
        love.graphics.pop()
    end
    
    love.graphics.draw(self.image, self.left, self.top)
    
end

return module