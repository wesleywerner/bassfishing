--[[
   weather.lua

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

--- Provides a weather system.
-- Values are randomly chosen based on sane ranges.
--
-- When there are enough clouds (coldFrontCloudsLimit) and wind
-- (coldFrontWindLimit) then a cold front will approach, and it hits
-- the following day. The front may last more than one day, and it will
-- be cold during this time with full cloud cover.
--
--
-- The feeding habits of bass:
-- * They feed more actively as the front approaches. high winds pump
--   oxygen into the water and provides food.
-- * They feed less after a cold front.

local module = {

    -- % of cloud cover
    cloudcover = 0,

    rain = false,

    airTemperature = 0,

    waterTemperature = 0,

    waterClarity = 0,

    windSpeed = 0,

    windDirection = "north",

    humidity = 0,

    approachingfront = false,

    coldfront = false,

    postfrontal = false,

    -- the human readable forecast
    forecast = nil

}


function module:change()

    local highWindSpeed = 35
    local chanceOfRain = 0.3
    local frontDissipatingChance = 0.5
    local cold = 15
    local average = 22
    local hot = 30
    -- % clouds for a cold front to hit
    local coldFrontCloudsLimit = 70
    local coldFrontWindLimit = highWindSpeed / 2
    -- % clouds to consider rain
    local rainCloudsLimit = 40
    -- % chance (0..1) of rain if rainCloudsLimit is met
    local rainChance = 0.2
    local clarities = { "clear", "murky" }
    local directions = { "N", "NE", "NW", "S", "SE", "SW", "E", "W" }

    self.forecast = ""

    -- air temperature considered hot
    hotLimit = 26

    self.cloudcover = math.random() * 100
    -- precipatation if there is enough clouds
    self.rain = (math.random() < rainChance) and (self.cloudcover > rainCloudsLimit)
    self.airTemperature = math.random(average, hot)
    self.waterTemperature = math.random(average, hot - 5)
    self.waterClarity = clarities[math.random(1, #clarities)]
    self.windSpeed = math.random(0, highWindSpeed)
    self.windDirection = directions[math.random(1, #directions)]
    self.humidity = math.random()

    -- switch to a post cold front
    if self.coldfront and math.random() < frontDissipatingChance then
        self.coldfront = false
        self.postfrontal = true
    else
        self.postfrontal = false
    end

    -- we now have a cold front.
    -- note that we are checking the previous day's "approachingfront" value
    -- here because this value is set below, during the previous day.
    if self.approachingfront then
        self.coldfront = true
        self.approachingfront = false
    end

    -- bring on a cold front from previous day's conditions.
    -- a cold front is preceeded by clouds and wind.
    if not self.coldfront then
        if self.cloudcover > coldFrontCloudsLimit and self.windSpeed > coldFrontWindLimit then
            self.approachingfront = true
        end
    end

    -- adjust weather with the fronts
    if self.approachingfront then
        game.dprint("A cold front is approaching!")
    elseif self.coldfront then
        game.dprint("A cold front is here!")
        self.airTemperature = math.random(cold, average - 4)
        self.waterTemperature = math.random(cold, average - 2)
        -- always rain during a cold front
        self.rain = true
        self.cloudcover = 100
    elseif self.postfrontal then
        game.dprint("the front has passed")
    end

    self.isHot = self.airTemperature > hotLimit

    -- update the forecast
    if self.approachingfront then
        self.forecast = "A cold front is approaching"
    elseif self.coldfront then
        self.forecast = "It is pretty darn cold"
    else
        -- reset
        self.forecast = ""
        -- heat
        if self.isHot then
            self.forecast = self.forecast .. "hot, "
        elseif self.airTemperature <= cold then
            self.forecast = self.forecast .. "cold, "
        end
        -- cloud cover
        if self.cloudcover <= 10 then
            self.forecast = self.forecast .. "clear "
        elseif self.cloudcover > 10 and self.cloudcover < rainCloudsLimit then
            self.forecast = self.forecast .. "partially cloudy "
        elseif self.cloudcover >= rainCloudsLimit then
            self.forecast = self.forecast .. "overcast "
        end
        -- wind
        if self.windSpeed <= 5 then
            self.forecast = self.forecast .. "and calm "
        elseif self.windSpeed > 5 and self.windSpeed < coldFrontWindLimit then
            self.forecast = self.forecast .. "and breezy "
        elseif self.windSpeed >= coldFrontWindLimit then
            self.forecast = self.forecast .. "and gusty "
        end
        -- rain
        if self.rain then
            self.forecast = self.forecast .. "with rain"
        end
    end

    game.dprint("\nThe weather is changing...")
    game.dprint(self.forecast)
    game.dprint(string.format("approachingfront\t: %s", tostring(self.approachingfront) ))
    game.dprint(string.format("coldfront\t\t: %s", tostring(self.coldfront) ))
    game.dprint(string.format("postfrontal\t\t: %s", tostring(self.postfrontal) ))
    game.dprint(string.format("cloudcover\t\t: %f", self.cloudcover ))
    game.dprint(string.format("rain\t\t\t: %s", tostring(self.rain) ))
    game.dprint(string.format("airTemperature\t\t: %d", self.airTemperature ))
    game.dprint(string.format("waterTemperature\t: %d", self.waterTemperature ))
    game.dprint(string.format("waterClarity\t\t: %s", self.waterClarity ))
    game.dprint(string.format("windSpeed\t\t: %d", self.windSpeed ))
    game.dprint(string.format("windDirection\t\t: %s", self.windDirection ))
    game.dprint(string.format("humidity\t\t: %f", self.humidity ))
    game.dprint("")

end

return module
