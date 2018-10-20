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

-- The game version
module.version = 2
module.title = "Bass Lover"

-- enable debug printing
module.debug = false
module.dprint = function(...) if module.debug then print(...) end end

-- global defaults
module.window = { }
module.window.width = 800
module.window.height = 600

-- re-usable screen border
module.border = love.graphics.newImage("res/screen-border.png")

module.defaultMapWidth = 80
module.defaultMapHeight = 30
module.defaultMapSeed = 0
module.defaultMapDensity = 0.25
module.defaultMapIterations = 6

-- solarized colors
module.color = { }
module.color.white     = { 255/255, 255/255, 255/255 }
module.color.base03    = {   0/255,  43/255,  54/255 }  -- darker background tones
module.color.base02    = {   7/255,  54/255,  66/255 }  -- dark background tones
module.color.base01    = {  88/255, 110/255, 117/255 }  -- darker content tones
module.color.base00    = { 101/255, 123/255, 131/255 }  -- dark content tones
module.color.base0     = { 131/255, 148/255, 150/255 }  -- light content tones
module.color.base1     = { 147/255, 161/255, 161/255 }  -- lighter content tones
module.color.base2     = { 238/255, 232/255, 213/255 }  -- light background tones
module.color.base3     = { 253/255, 246/255, 227/255 }  -- lighter background tones
module.color.yellow    = { 181/255, 137/255,   0/255 }
module.color.orange    = { 203/255,  75/255,  22/255 }
module.color.red       = { 220/255,  50/255,  47/255 }
module.color.magenta   = { 211/255,  54/255, 130/255 }
module.color.violet    = { 108/255, 113/255, 196/255 }
module.color.blue      = {  38/255, 139/255, 210/255 }
module.color.cyan      = {  42/255, 161/255, 152/255 }
module.color.green     = { 133/255, 153/255,   0/255 }
module.color.hilite    = {  38/255, 139/255, 210, 64/255 }
module.color.checked   = { 133/255, 153/255,   0, 64/255 }
module.color.lightbackground = module.color.base2
module.color.darkbackground = module.color.base02
module.color.lighttext = module.color.base1
module.color.darktext = module.color.base00
module.color.notifybackground = { 7/255, 54/255, 66/255, 192/255 }
module.color.notifyurgentbackground = { 220/255, 50/255, 47/255, 192/255 }
module.color.notifytext = { 253/255, 246/255, 227/255, 230/255 }

-- screen transition defaults
module.transition = {
    time = 1,
    enter = "outBack",
    exit = "inBack"
}

-- collate modules
module.logic = { }
module.view = { }
module.lib = { }

-- game states
module.states = require("logic.states")

-- game music
module.music = require("music.music")
module.sound = require("sound.sound")

-- logic modules
--module.logic.array2d = require("logic.array2d")
module.logic.genie = require("logic.lakegenerator")
module.logic.boat = require("logic.boat")
module.logic.player = require("logic.player")
module.logic.competitors = require("logic.competitors")
module.logic.fish = require("logic.fish")
module.logic.weather = require("logic.weather")
module.logic.livewell = require("logic.live-well")
module.logic.tournament = require("logic.tournament")
module.logic.tackle = require("logic.tackle")
module.logic.toplunkers = require("logic.top-lunkers")
module.logic.pickle = require("logic.pickle")
module.logic.anglers = require("logic.anglers")
module.logic.stats = require("logic.stats")
module.logic.options = require("logic.options")

-- view modules
module.view.messages = require("views.messages")
module.view.maprender = require("views.maprender")
module.view.fishfinder = require("views.fishfinder")
module.view.tiles = require("views.tiles")
module.view.player = require("views.player")
module.view.competitors = require("views.competitors")
module.view.fish = require("views.fish")
module.view.weather = require("views.weather-display")
module.view.clock = require("views.clock")
module.view.screentransition = require("views.screen-transition")
module.view.ui = require("views.ui")
module.view.notify = require("views.notification")

-- libraries
module.lib.camera = require("libs.harness.camera")
module.lib.trig = require("libs.harness.trig")
module.lib.hotspot = require("libs.harness.hotspot")
module.lib.button = require("libs.harness.button")
module.lib.widgetCollection = require("libs.harness.widgetcollection")
module.lib.aperture = require("libs.harness.aperture")
module.lib.chart = require("libs.harness.chart")
module.lib.lume = require("libs.lume.lume")
module.lib.luastar = require("libs.lua-star.src.lua-star")
module.lib.list = require("libs.list")
module.lib.tween = require("libs.tween.tween")
module.lib.convert = require("libs.conversion")

-- fonts
module.fonts = { }
module.fonts.tiny = love.graphics.newFont("res/MechanicalBd.otf", 14)
module.fonts.tinyheight = module.fonts.tiny:getHeight()
module.fonts.small = love.graphics.newFont("res/MechanicalBd.otf", 18)
module.fonts.smallheight = module.fonts.small:getHeight()
module.fonts.medium = love.graphics.newFont("res/MechanicalBd.otf", 24)
module.fonts.mediumheight = module.fonts.medium:getHeight()
module.fonts.large = love.graphics.newFont("res/MechanicalBdOutObl.otf", 48)
module.fonts.largeheight = module.fonts.large:getHeight()

return module
