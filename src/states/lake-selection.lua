--[[
   lake-selection.lua

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

local module = { }

-- set up the lake list
local lakelist = game.lib.list:new()
lakelist:add("Crystal Lake")
lakelist:add("Wesley's Pond")
lakelist:add("Midlands Reservoir")

function lakelist.drawItem(id, item, selected)
    if selected then
        love.graphics.setColor(game.color.blue)
    else
        love.graphics.setColor(game.color.base1)
    end
    love.graphics.print(item, 100, 100 + (id * 24))
end

local function seedFromString(name)

    local seed = 0
    local len = string.len(name)
    for i=1, len do
        seed = seed + string.byte(name, i)
    end
    return seed

end

local function newMap(seed)

    game.lake = game.logic.genie:generate(game.defaultMapWidth,
    game.defaultMapHeight, seed,
    game.defaultMapDensity, game.defaultMapIterations)

    -- clear the map canvas so it redraws itself
    module.lakepreview = nil

end

function module:init()

    love.graphics.setFont(game.fonts.medium)
    newMap(seedFromString(lakelist:selectedItem()))

end


function module:keypressed(key)
    if key == "escape" or key == "f10" then
        game.states:pop()
    elseif key == "left" then
        newMap(seedFromString("wesley werner"))
    elseif key == "right" then
        game.lake = game.logic.genie:generate( game.lake.width, game.lake.height,
        math.max(0, game.lake.seed + 1), game.lake.density,
        game.lake.iterations)
        self:reset()
    elseif key == "up" then
        lakelist:selectPrev()
        newMap(seedFromString(lakelist:selectedItem()))
    elseif key == "down" then
        lakelist:selectNext()
        newMap(seedFromString(lakelist:selectedItem()))
    elseif key == "return" then
        game.states:push("development")
    end
end

function module:update(dt)

end

function module:draw()

    love.graphics.clear(game.color.base02)

    -- title
    love.graphics.setColor(game.color.cyan)
    love.graphics.printf("Where do you want to fish today?", 0, 40, game.window.width, "center")

    lakelist:draw()

    -- cache the lake preview to canvas
    if not self.lakepreview then
        self.lakepreview = game.view.minimap.render()
    end

    -- scale the map to fit
    love.graphics.push()
    love.graphics.translate(0, 200)
    love.graphics.scale(6, 6)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.lakepreview, 0, 0)
    love.graphics.pop()

end

return module
