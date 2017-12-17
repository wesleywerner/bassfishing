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

-- pre-calculate centering lake on screen
module.lakeScale = 6
module.lakeCenter = (game.window.width / module.lakeScale / 2) - (game.defaultMapWidth / 2)
module.lakeBottom = (game.window.height / module.lakeScale / 2) + (game.defaultMapHeight / 2)

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
    love.graphics.printf(item, 0, 140 + (id * 40), game.window.width, "center")
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

    newMap(seedFromString(lakelist:selectedItem()))

end


function module:keypressed(key)
    if key == "escape" or key == "f10" then
        game.states:pop()
    elseif key == "up" then
        lakelist:selectPrev()
        newMap(seedFromString(lakelist:selectedItem()))
    elseif key == "down" then
        lakelist:selectNext()
        newMap(seedFromString(lakelist:selectedItem()))
    elseif key == "return" then
        game.states:push("tournament")
    end
end

function module:update(dt)

end

function module:draw()

    love.graphics.clear(game.color.base02)

    -- title
    love.graphics.setFont(game.fonts.large)
    love.graphics.setColor(game.color.cyan)
    love.graphics.printf("Where do you want to fish today?", 0, 40, game.window.width, "center")

    love.graphics.setFont(game.fonts.medium)
    lakelist:draw()

    -- cache the lake preview to canvas
    if not self.lakepreview then
        self.lakepreview = game.view.maprender.renderMini()
    end

    -- scale the map to fit
    love.graphics.push()
    love.graphics.scale(6, 6)
    love.graphics.translate(self.lakeCenter, self.lakeBottom)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.lakepreview, 0, 0)
    love.graphics.setColor(game.color.violet)
    love.graphics.rectangle("line", 0, 0, game.lake.width, game.lake.height)
    love.graphics.pop()

end

return module
