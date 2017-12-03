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

    -- position of the graph (to fit within the background)
    left = 27,
    top = 12,

    -- size of the graph
    graphWidth = 110,
    graphHeight = 114,

    -- border image
    background = nil,

    -- total size
    width = 0,
    height = 0,
}

local glob = require("globals")
local player = require("player")
local weather = require("weather")

function module:update()

    local depth = glob.lake.depth[player.x][player.y]
    local structure = glob.lake.structure[player.x][player.y]
    local fishamt = 0

    -- count fish
    for _, fish in ipairs(glob.lake.fish) do
        if fish.x == player.x and fish.y == player.y then
            fishamt = fishamt + 1
        end
    end

    -- Fill the points list if empty
    if #self.points == 0 then
        for n=1, self.history do
            table.insert(self.points, {
                depth = depth,
                fish = 0,
                structure = structure
            })
        end
    else
        table.insert(self.points, {
            depth = depth,
            fish = fishamt,
            structure = structure
        })
    end

    -- remove old
    while #self.points > self.history do
       table.remove(self.points, 1)
    end

    self.refresh = true

end

function module:render()


    if self.refresh then

        if not self.background then

            -- border image
            self.background = love.graphics.newImage("res/fishfinder3000.png")

            -- total size
            self.width = self.background:getWidth()
            self.height = self.background:getHeight()

        end

        love.graphics.push()
        --love.graphics.setFont( love.graphics.newFont( 20 ) )

        -- render to canvas
        local backgroundcolor = { 140, 185, 164 }
        local foregroundcolor = { 0, 85, 182, 128 }

        -- create new graph canvas
        self.image = nil
        self.image = love.graphics.newCanvas( self.graphWidth, self.graphHeight )
        love.graphics.setCanvas(self.image)
        love.graphics.setColor(foregroundcolor)

        -- build the list of depth vertices
        local vertices = { 0, self.graphHeight + 1 } -- ensure start point is an extremity

        for n, point in ipairs(self.points) do

            -- history moves from right to left
            local px = ( self.graphWidth / (self.history) ) * (n-1)

            -- depth 0=bottom 1=surface
            local py = self.graphHeight - ( self.graphHeight * point.depth )

            -- vary the bottom for variety
            py = math.max(1, py - math.random(0, 6))

            table.insert(vertices, px)
            table.insert(vertices, py)

            -- draw a fish
            for fishid=1, point.fish do
                love.graphics.print("^", px, py - 20 - (fishid*2))
            end

            if point.structure then
                love.graphics.print("=", px, py - 60)
            end

        end

        -- insert a bottom-right vertice as the last position.
        -- this completes a polygon
        table.insert(vertices, self.graphWidth)
        table.insert(vertices, vertices[#vertices-1])
        table.insert(vertices, self.graphWidth)
        table.insert(vertices, self.graphHeight + 1) -- ensure end point is an extremity

        -- draw the graph
        love.graphics.setLineJoin("none")
        local triangles = love.math.triangulate ( vertices )
        for triNo, triangle in ipairs ( triangles ) do
            love.graphics.polygon ( "fill", triangle )
        end

        -- print the water temperature
        love.graphics.print(string.format("%d°C", weather.waterTemperature), 0, 0)

        love.graphics.setCanvas()
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth( 1 )

        self.refresh = false
        love.graphics.pop()

    end

end

function module:draw()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.background, 0, 0)
    love.graphics.draw(self.image, self.left, self.top)

end

return module
