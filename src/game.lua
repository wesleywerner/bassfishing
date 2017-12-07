--[[
   game.lua

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

-- enable debug printing
module.debug = true
module.dprint = function(...) if module.debug then print(...) end end

-- global defaults
module.window = { }
module.window.width = 800
module.window.height = 600

module.defaultMapWidth = 80
module.defaultMapHeight = 30
module.defaultMapSeed = 0
module.defaultMapDensity = 0.25
module.defaultMapIterations = 6

-- collate modules
module.logic = { }
module.view = { }
module.lib = { }

-- game states
module.states = require("logic.states")

-- logic modules
--module.logic.array2d = require("logic.array2d")
module.logic.genie = require("logic.lakegenerator")
module.logic.boat = require("logic.boat")
module.logic.player = require("logic.player")
module.logic.competitors = require("logic.competitors")
module.logic.fish = require("logic.fish")
module.logic.weather = require("logic.weather")
module.logic.livewell = require("logic.livewell")
module.logic.tournament = require("logic.tournament")

-- view modules
module.view.messages = require("views.messages")
module.view.maprender = require("views.maprender")
module.view.fishfinder = require("views.fishfinder")
module.view.tiles = require("views.tiles")
module.view.player = require("views.player")
module.view.competitors = require("views.competitors")
module.view.fish = require("views.fish")
module.view.weather = require("views.weather-display")
module.view.livewell = require("views.livewell")

-- libraries
module.lib.camera = require("libs.camera")
module.lib.lume = require("libs.lume")
module.lib.luastar = require("libs.lua-star")

-- fonts
module.fonts = { }
module.fonts.color = { 146, 182, 222 }
module.fonts.small = love.graphics.newFont("res/TruenoRg.otf", 16)
module.fonts.medium = love.graphics.newFont("res/TruenoRg.otf", 20)
module.fonts.large = love.graphics.newFont("res/TruenoBlkOl.otf", 48)

--TODO: Move these to one of our libs
local lume = require("libs.lume")

--- Returns a point on a circle.
--
-- @tparam number cx
-- The origin of the circle
--
-- @tparam number cy
-- The origin of the circle
--
-- @tparam number r
-- The circle radius
--
-- @tparam number a
-- The angle of the point to the origin.
--
-- @treturn number
-- x, y
function module:pointOnCircle(cx, cy, r, a)

    x = cx + r * math.cos(a)
    y = cy + r * math.sin(a)
    return x, y

end

--- Clamp a point to a circular range.
--
-- @tparam number cx
-- The origin of the circle
--
-- @tparam number cy
-- The origin of the circle
--
-- @tparam number x
-- The goal point to reach
--
-- @tparam number y
-- The goal point to reach
--
-- @tparam number r
-- The circle radius
--
-- @treturn number
-- x, y
function module:limitPointToCircle(cx, cy, x, y, r)

    -- distance
    local dist = lume.distance(cx, cy, x, y)

    -- if within the required range
    if dist <= r then
        return x, y
    end

    -- otherwise clamp the point to the radius limit
    r = math.min(r, dist)

    -- angle
    local a = lume.angle(cx, cy, x, y)

    return self:pointOnCircle(cx, cy, r, a)

end


return module
