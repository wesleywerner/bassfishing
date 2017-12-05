--[[
   weatherdisplay.lua

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

    forecolor = { 146, 182, 222 },

    icons = nil,

    -- positions of drawn items
    -- All drawings a relative to the info bar position
    daypos = { 5, 2 },
    iconpos = { 60, 30 },
    timepos = { 30, 2, 140, "right" },    -- including limit, align
    temppos = { 30, 86, 140, "right" },
    cloudpos = { 30, 116, 140, "right" },
    windpos = { 30, 146, 140, "right" },

}

local weather = require("weather")

function module:draw()

    love.graphics.push()
    --love.graphics.translate()

    -- print day and time
    love.graphics.setColor(self.forecolor)
    love.graphics.print("Day 1", unpack(self.daypos))
    love.graphics.printf("4h 30m", unpack(self.timepos))

    -- print temp, cloud cover and wind
    love.graphics.printf(string.format("%d°C", weather.airTemperature),
        unpack(self.temppos))
    love.graphics.printf(string.format("%d%%", weather.cloudcover),
        unpack(self.cloudpos))
    love.graphics.printf(string.format("%dkph %s",
        weather.windSpeed, weather.windDirection), unpack(self.windpos))

    -- the weather icon priority is:
    -- approaching cold fronts
    -- very hot
    -- rainy
    -- cloudy
    -- windy
    -- overcast
    love.graphics.setColor(255, 255, 255)
    local icon = self.icons.clear

    if weather.approachingfront then
        icon = self.icons.cloudygusts
    elseif weather.isHot then
        icon = self.icons.hot
    elseif weather.rain then
        icon = self.icons.rainy
    elseif weather.cloudcover > 30 and weather.windSpeed > 20 then
        icon = self.icons.cloudygusts
    elseif weather.cloudcover > 30 then
        icon = self.icons.cloudy
    elseif weather.windSpeed > 20 then
        icon = self.icons.windy
    elseif weather.cloudcover > 10 then
        icon = self.icons.overcast
    end

    love.graphics.draw(self.icons.image, icon, unpack(self.iconpos))

    love.graphics.pop()

end

if not module.icons then

    module.icons = { }
    module.icons.image = love.graphics.newImage("res/weather-icons.png")
    module.icons.w, module.icons.h = module.icons.image:getDimensions()

    -- hot days
    module.icons.hot = love.graphics.newQuad(0, 0, 60, 60, module.icons.w, module.icons.h)
    -- windy days
    module.icons.windy = love.graphics.newQuad(60, 0, 60, 60, module.icons.w, module.icons.h)
    -- lighty overcast
    module.icons.overcast = love.graphics.newQuad(120, 0, 60, 60, module.icons.w, module.icons.h)
    -- clear
    module.icons.clear = love.graphics.newQuad(180, 0, 60, 60, module.icons.w, module.icons.h)
    -- rain
    module.icons.rainy = love.graphics.newQuad(240, 0, 60, 60, module.icons.w, module.icons.h)
    -- cloudy and windy
    module.icons.cloudygusts = love.graphics.newQuad(300, 0, 60, 60, module.icons.w, module.icons.h)
    -- heavy clouds
    module.icons.cloudy = love.graphics.newQuad(360, 0, 60, 60, module.icons.w, module.icons.h)

end

return module
