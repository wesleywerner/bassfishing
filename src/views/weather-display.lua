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

local module = { }

-- alias to the weather logic
local weather = nil

-- remember the time the icon was last refreshed
local forecastTime = nil

-- current forecast icon
local forecastIcon = nil

-- size of the icon
local iconSize = 60

function module:drawIcon()

    -- alias weather
    if not weather then
        weather = game.logic.weather
    end

    -- refresh the icon
    if forecastTime ~= weather.time or not forecastIcon then

        -- record the time we updated the icon
        forecastTime = weather.time

        -- the weather icon priority is:
        -- approaching cold fronts
        -- very hot
        -- rainy
        -- cloudy
        -- windy
        -- overcast
        forecastIcon = self.icons.clear

        if weather.approachingfront then
            forecastIcon = self.icons.cloudygusts
        elseif weather.coldfront then
            forecastIcon = self.icons.coldfront
        elseif weather.isHot then
            forecastIcon = self.icons.hot
        elseif weather.rain then
            forecastIcon = self.icons.rainy
        elseif weather.cloudcover > 30 and weather.windSpeed > 20 then
            forecastIcon = self.icons.cloudygusts
        elseif weather.cloudcover > 30 then
            forecastIcon = self.icons.cloudy
        elseif weather.windSpeed > 20 then
            forecastIcon = self.icons.windy
        elseif weather.cloudcover > 10 then
            forecastIcon = self.icons.overcast
        end

    end

    -- TODO: move scale to init
    love.graphics.draw(self.icons.image, forecastIcon, 0, 0, 0, game.window.scale, game.window.scale)

end

if not module.icons then

    module.icons = { }
    module.icons.image = love.graphics.newImage("res/weather-icons.png")
    module.icons.w, module.icons.h = module.icons.image:getDimensions()
    local w, h = module.icons.w, module.icons.h

    -- hot days
    module.icons.hot = love.graphics.newQuad(1, 1, iconSize, iconSize, w, h)

    -- windy days
    module.icons.windy = love.graphics.newQuad(62, 1, iconSize, iconSize, w, h)

    -- lighty overcast
    module.icons.overcast = love.graphics.newQuad(123, 1, iconSize, iconSize, w, h)

    -- clear
    module.icons.clear = love.graphics.newQuad(184, 1, iconSize, iconSize, w, h)

    -- rain
    module.icons.rainy = love.graphics.newQuad(245, 1, iconSize, iconSize, w, h)

    -- cloudy and windy
    module.icons.cloudygusts = love.graphics.newQuad(306, 1, iconSize, iconSize, w, h)

    -- heavy clouds
    module.icons.cloudy = love.graphics.newQuad(367, 1, iconSize, iconSize, w, h)

    -- cold front
    module.icons.coldfront = love.graphics.newQuad(428, 1, iconSize, iconSize, w, h)

    -- small icons
    module.icons.smallthermometer = love.graphics.newQuad(489, 1, 30, 30, w, h)
    module.icons.smallcloud = love.graphics.newQuad(520, 1, 30, 30, w, h)
    module.icons.smallwind = love.graphics.newQuad(551, 1, 30, 30, w, h)
    module.icons.smallclock = love.graphics.newQuad(582, 1, 30, 30, w, h)

end

function module:drawThermometer()

    love.graphics.draw(self.icons.image, self.icons.smallthermometer, 0, 0)

end

function module:drawCloud()

    love.graphics.draw(self.icons.image, self.icons.smallcloud, 0, 0)

end

function module:drawWind()

    love.graphics.draw(self.icons.image, self.icons.smallwind, 0, 0)

end

return module
