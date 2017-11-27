--[[
   maprender.lua

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
local glob = require("globals")
local tiles = require("tiles")


--- Get the quad to draw a corner of water as interpolated by the land around it.
local function getWaterCorner(a, x, y)

    local leftX = math.max(1, x-1)
    local rightX = math.min(#a, x+1)
    local topY = math.max(1, y-1)
    local bottomY = math.min(#a[1], y+1)

    local left = a[leftX][y] > 0
    local top = a[x][topY] > 0
    local right = a[rightX][y] > 0
    local bottom = a[x][bottomY] > 0

    if top and bottom and left and not right then
        return tiles.water.leftalcove
    elseif top and bottom and right and not left then
        return tiles.water.rightalcove
    elseif left and right and top and not bottom then
        return tiles.water.topalcove
    elseif left and right and bottom and not top then
        return tiles.water.bottomalcove
    elseif top and left then
        return tiles.water.topleft
    elseif top and right then
        return tiles.water.topright
    elseif bottom and left then
        return tiles.water.bottomleft
    elseif bottom and right then
        return tiles.water.bottomright
    elseif left then
        return tiles.water.left
    elseif right then
        return tiles.water.right
    elseif top then
        return tiles.water.top
    elseif bottom then
        return tiles.water.bottom
    else
        return tiles.water.open
    end

end


function module:render()

    -- already rendered
    if glob.lake.rendered then
        return true
    end

    local tilesize = 16
    local lake = glob.lake

    self.image = nil
    self.image = love.graphics.newCanvas( (lake.width+1)*tilesize, (lake.height+1)*tilesize )

    love.graphics.setCanvas(self.image)

    for x=1, lake.width do
    for y=1, lake.height do

        local ground = lake.contour[x][y] > 0

        love.graphics.setColor(255, 255, 255)

        if ground then
            love.graphics.draw(tiles.image, tiles.land, x*16, y*16)
        else
            -- draw open water tile
            love.graphics.draw(tiles.image, tiles.water.open, x*16, y*16)
            -- and any special corner tile
            local waterquad = getWaterCorner(lake.contour, x, y)
            love.graphics.draw(tiles.image, waterquad, x*16, y*16)
        end

        local plantid = lake.plants[x][y]
        if plantid > 0 then
            local plantidx = math.max(1, plantid % #tiles.plants)
            love.graphics.draw(tiles.image, tiles.plants[plantidx], x*16, y*16)
        end

        local treeid = lake.trees[x][y]
        if treeid > 0 then
            local treeidx = math.max(1, treeid % #tiles.trees)
            love.graphics.draw(tiles.image, tiles.trees[treeidx], x*16, y*16)
        end

        local house = lake.buildings[x][y] > 0
        if house then
            local id = math.random(1, #tiles.buildings)
            love.graphics.draw(tiles.image, tiles.buildings[id], x*16, y*16)
        end

    end
    end

    -- Draw jetties
    for _, jetty in ipairs(lake.jetties) do
        if jetty.horizontal then
            love.graphics.draw(tiles.image, tiles.jetties.horizontal, jetty.x*16, jetty.y*16)
        else
            love.graphics.draw(tiles.image, tiles.jetties.vertical, jetty.x*16, jetty.y*16)
        end
    end

    -- Draw obstacles
    for _, obs in ipairs(lake.obstacles) do
        if obs.log then
            local id = math.random(1, #tiles.obstacles.logs)
            love.graphics.draw(tiles.image, tiles.obstacles.logs[id], obs.x*16, obs.y*16)
        elseif obs.rock then
            local id = math.random(1, #tiles.obstacles.rocks)
            love.graphics.draw(tiles.image, tiles.obstacles.rocks[id], obs.x*16, obs.y*16)
        elseif obs.boat then
            local id = math.random(1, #tiles.boats)
            love.graphics.draw(tiles.image, tiles.boats[id], obs.x*16, obs.y*16)
        end
    end

    love.graphics.setCanvas()

    -- flag the map as rendered
    glob.lake.rendered = true

end


return module
