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

function module:drawIcon()

    -- TODO: hover over tips (a cold front is approaching etc)

    local weather = game.logic.weather
    --love.graphics.push()
    --love.graphics.setFont(game.fonts.medium)
    --love.graphics.setColor(game.color.base1)

    ---- print temp
    --love.graphics.draw(self.icons.image, self.icons.smallthermometer, 0, 86)
    --love.graphics.print(game.lib.convert:temp(weather.airTemperature), 40, 86)

    ---- print cloud cover
    --love.graphics.draw(self.icons.image, self.icons.smallcloud, 0, 116)
    --love.graphics.print(string.format("%d%%", weather.cloudcover), 40, 116)

    ---- print wind
    --love.graphics.draw(self.icons.image, self.icons.smallwind, 0, 146)
    --love.graphics.print(string.format("%s %s", game.lib.convert:speed(weather.windSpeed), weather.windDirection), 40, 146)

    -- the weather icon priority is:
    -- approaching cold fronts
    -- very hot
    -- rainy
    -- cloudy
    -- windy
    -- overcast
    love.graphics.setColor(game.color.base1)
    local icon = self.icons.clear

    if weather.approachingfront then
        icon = self.icons.cloudygusts
    elseif weather.coldfront then
        icon = self.icons.coldfront
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

    love.graphics.draw(self.icons.image, icon) --, 0, 0, 0, .9, .9)

    --love.graphics.pop()

end

if not module.icons then

    module.icons = { }
    module.icons.image = love.graphics.newImage("res/weather-icons.png")
    module.icons.w, module.icons.h = module.icons.image:getDimensions()
    local w, h = module.icons.w, module.icons.h

    -- hot days
    module.icons.hot = love.graphics.newQuad(1, 1, 60, 60, w, h)

    -- windy days
    module.icons.windy = love.graphics.newQuad(62, 1, 60, 60, w, h)

    -- lighty overcast
    module.icons.overcast = love.graphics.newQuad(123, 1, 60, 60, w, h)

    -- clear
    module.icons.clear = love.graphics.newQuad(184, 1, 60, 60, w, h)

    -- rain
    module.icons.rainy = love.graphics.newQuad(245, 1, 60, 60, w, h)

    -- cloudy and windy
    module.icons.cloudygusts = love.graphics.newQuad(306, 1, 60, 60, w, h)

    -- heavy clouds
    module.icons.cloudy = love.graphics.newQuad(367, 1, 60, 60, w, h)

    -- cold front
    module.icons.coldfront = love.graphics.newQuad(428, 1, 60, 60, w, h)

    -- small icons
    module.icons.smallthermometer = love.graphics.newQuad(489, 1, 30, 30, w, h)
    module.icons.smallcloud = love.graphics.newQuad(520, 1, 30, 30, w, h)
    module.icons.smallwind = love.graphics.newQuad(551, 1, 30, 30, w, h)
    module.icons.smallclock = love.graphics.newQuad(582, 1, 30, 30, w, h)

end

return module
