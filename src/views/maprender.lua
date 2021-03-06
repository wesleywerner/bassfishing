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


--- Get the quad to draw a corner of water as interpolated by the land around it.
local function getWaterCorner(a, x, y)

    local tiles = game.view.tiles
    local leftX = math.max(1, x-1)
    local rightX = math.min(#a, x+1)
    local topY = math.max(1, y-1)
    local bottomY = math.min(#a[1], y+1)

    -- these flags are true if they point to land
    local left = a[leftX][y] > 0
    local top = a[x][topY] > 0
    local right = a[rightX][y] > 0
    local bottom = a[x][bottomY] > 0

    if top and bottom and left and not right then
        return tiles.alcove.left
    elseif top and bottom and right and not left then
        return tiles.alcove.right
    elseif left and right and top and not bottom then
        return tiles.alcove.top
    elseif left and right and bottom and not top then
        return tiles.alcove.bottom
    elseif top and left then
        return tiles.land.inset.topleft
    elseif top and right then
        return tiles.land.inset.topright
    elseif bottom and left then
        return tiles.land.inset.bottomleft
    elseif bottom and right then
        return tiles.land.inset.bottomright
    end

end

--- Get the quad to draw a corner of water as interpolated by the land around it.
local function getLandCorner(a, x, y)

    local tiles = game.view.tiles
    local leftX = math.max(1, x-1)
    local rightX = math.min(#a, x+1)
    local topY = math.max(1, y-1)
    local bottomY = math.min(#a[1], y+1)

    -- these flags are true if they point to land
    local left = a[leftX][y] > 0
    local top = a[x][topY] > 0
    local right = a[rightX][y] > 0
    local bottom = a[x][bottomY] > 0

    --TODO: ensure all top/left/bot/rt are checked

    if right and not top and not left and not bottom then
        -- point left
        return tiles.land.point.left
    elseif left and not top and not bottom and not right then
        -- point right
        return tiles.land.point.right
    elseif bottom and not left and not top and not right then
        -- point top
        return tiles.land.point.top
    elseif top and not bottom and not left and not right then
        -- bottom point
        return tiles.land.point.bottom
    elseif right and bottom and not left and not top then
        -- corner
        return tiles.land.corner.topleft
    elseif left and not right and not top and bottom then
        -- corner
        return tiles.land.corner.topright
    elseif top and not bottom and not left and right then
        -- corner
        return tiles.land.corner.bottomleft
    elseif left and top and not right and not bottom then
        -- corner
        return tiles.land.corner.bottomright
    else
        return tiles.land.open
    end

end

function module:render()

    -- already rendered
    if game.lake.rendered then
        return true
    end

    local tiles = game.view.tiles
    local lake = game.lake

    self.image = nil
    self.image = love.graphics.newCanvas( (lake.width+1) * tiles.size, (lake.height+1) * tiles.size )

    love.graphics.setCanvas(self.image)

    for x=1, lake.width do
    for y=1, lake.height do

        local drawx = (x-1) * tiles.size
        local drawy = (y-1) * tiles.size

        local ground = lake.contour[x][y] > 0

        -- draw water depth with a different shade
        -- local depth = 192 + (lake.depth[x][y] * 63)
        -- love.graphics.setColor(depth, depth, depth)

        -- overcast days show darker water
        local shade = math.max(128, 220 - game.logic.weather.cloudcover)
        love.graphics.setColor(shade, shade, shade)

        if ground then
            -- underlay open water to fill in any edges from the land
            love.graphics.draw(tiles.image, tiles.water, drawx, drawy)
            -- get the land tile
            local landquad = getLandCorner(lake.contour, x, y)
            love.graphics.setColor(255, 255, 255)
            love.graphics.draw(tiles.image, landquad, drawx, drawy)
        else
            -- draw open water tile
            love.graphics.draw(tiles.image, tiles.water, drawx, drawy)
            -- and any special corner tile
            local waterquad = getWaterCorner(lake.contour, x, y)
            if waterquad then
                love.graphics.setColor(255, 255, 255)
                love.graphics.draw(tiles.image, waterquad, drawx, drawy)
            end
        end

        local plantid = lake.plants[x][y]
        if plantid > 0 then
            local plantidx = math.max(1, plantid % #tiles.plants)
            love.graphics.setColor(255, 255, 255, 128)
            love.graphics.draw(tiles.image, tiles.plants[plantidx], drawx, drawy)
        end

        local treeid = lake.trees[x][y]
        if treeid > 0 then
            love.graphics.setColor(255, 255, 255)
            local treeidx = math.max(1, treeid % #tiles.trees)
            love.graphics.draw(tiles.image, tiles.trees[treeidx], drawx, drawy)
        end

        local house = lake.buildings[x][y] > 0
        if house then
            love.graphics.setColor(255, 255, 255)
            local id = math.random(1, #tiles.buildings)
            love.graphics.draw(tiles.image, tiles.buildings[id], drawx, drawy)
        end

    end
    end

    -- Draw jetties
    for _, jetty in ipairs(lake.jetties) do
        local drawx = (jetty.x-1) * tiles.size
        local drawy = (jetty.y-1) * tiles.size
        if jetty.horizontal then
            love.graphics.draw(tiles.image, tiles.jetties.horizontal, drawx, drawy)
        else
            love.graphics.draw(tiles.image, tiles.jetties.vertical, drawx, drawy)
        end
    end

    -- Draw obstacles
    love.graphics.setColor(255, 255, 255, 192)
    for _, obs in ipairs(lake.obstacles) do
        local drawx = (obs.x-1) * tiles.size
        local drawy = (obs.y-1) * tiles.size
        if obs.log then
            local id = math.random(1, #tiles.obstacles.logs)
            love.graphics.draw(tiles.image, tiles.obstacles.logs[id], drawx, drawy)
        elseif obs.rock then
            local id = math.random(1, #tiles.obstacles.rocks)
            love.graphics.draw(tiles.image, tiles.obstacles.rocks[id], drawx, drawy)
        elseif obs.boat then
            local id = math.random(1, #tiles.boats)
            love.graphics.draw(tiles.image, tiles.boats[id], drawx, drawy)
        end
    end

    love.graphics.setCanvas()

    -- flag the map as rendered
    game.lake.rendered = true

end

-- Render a preview of the lake contour to a canvas
function module:renderMini(showPlayer)

    local preview = love.graphics.newCanvas(game.lake.width, game.lake.height)
    love.graphics.setCanvas(preview)

    -- compensate drawing one-based coordinates on a zero-based canvas
    love.graphics.push()
    love.graphics.translate(-1, -1)

    for x=1, game.lake.width do
        for y=1, game.lake.height do

            local land = game.lake.contour[x][y] > 0

            if land then
                love.graphics.setColor(game.color.base03)
                love.graphics.rectangle("fill", x, y, 1, 1)
            else
                -- draw lake depth
                local depth = game.lake.depth[x][y]
                love.graphics.setColor(game.color.blue)
                love.graphics.rectangle("fill", x, y, 1, 1)
            end

        end
    end

    -- Jetties
    love.graphics.setColor(game.color.yellow)
    for _, jetty in ipairs(game.lake.jetties) do
        love.graphics.rectangle("fill", jetty.x, jetty.y, 1, 1)
    end

    -- Player boat
    if showPlayer and game.logic.player.x then
        love.graphics.setColor(game.color.base3)
        love.graphics.rectangle("fill", game.logic.player.x, game.logic.player.y, 1, 1)
    end

    love.graphics.pop()
    love.graphics.setCanvas()

    return preview

end


return module
