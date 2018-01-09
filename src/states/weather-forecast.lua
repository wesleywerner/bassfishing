--[[
   weather-forecast.lua
   bass lover


   Copyright 2018 wesley werner <wesley.werner@gmail.com>

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

-- size of the icon
local iconSize = 60

-- useful hints
local hints = {
    ["approaching"] = "Fish are in a feeding frenzy",
    ["cold"] = "Fish are cold and sluggish",
    ["postal"] = "Fish are glutted and lazy",
    ["other"] = "It is a great day to fish!"
}

function module:init(data)

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage(love.graphics.newScreenshot())

    -- alias weather
    if not weather then
        weather = game.logic.weather
    end

    -- size of the forecast box (in percentage of screen size)
    local boxsize = 0.8
    self.width = boxsize * game.window.width
    self.height = boxsize * game.window.height
    self.left = (game.window.width - self.width) / 2
    self.top = (game.window.height - self.height) / 2

    -- useful hint position
    self.hintTop = self.top + self.height - 60

    -- icon position centered
    self.iconLeft = self.left + (self.width - iconSize) / 2
    self.iconTop = self.top + iconSize

    -- human readable forecast position
    self.readableTop = self.iconTop + iconSize

    -- weather details
    self.detailsLeft = self.left + 200
    self.detailsTop = self.readableTop + iconSize
    self.details = love.graphics.newText(game.fonts.medium)

    local airtemp = game.lib.convert:temp(weather.airTemperature)
    local cloudcover = string.format("%d%%", weather.cloudcover)
    local windspeed = game.lib.convert:speed(weather.windSpeed)
    local windspeedanddir = string.format("%s %s", windspeed, weather.windDirection)
    local withrain = weather.rain and "and rainy" or ""
    local humidity = string.format("%d%%", weather.humidity * 100)

    -- temperature
    self.details:add("Temperature", 0, 0)
    self.details:add(airtemp, 200, 0)

    -- cloud cover
    self.details:add("Cloud cover", 0, game.fonts.mediumheight)
    self.details:add(string.format("%d%% %s", weather.cloudcover, withrain), 200, game.fonts.mediumheight)

    -- wind
    self.details:add("Wind speed", 0, game.fonts.mediumheight * 2)
    self.details:add(windspeedanddir, 200, game.fonts.mediumheight * 2)

    -- water clarity
    self.details:add("Water", 0, game.fonts.mediumheight * 3)
    self.details:add(weather.waterClarity, 200, game.fonts.mediumheight * 3)

    -- humidity
    self.details:add("Humidity", 0, game.fonts.mediumheight * 4)
    self.details:add(humidity, 200, game.fonts.mediumheight * 4)

    -- screen transition
    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

end

function module:keypressed(key)

    self.transition:close(game.transition.time, game.transition.exit)

end

function module:mousemoved(x, y, dx, dy, istouch)

end

function module:mousepressed(x, y, button, istouch)

    self:keypressed("escape")

end

function module:mousereleased(x, y, button, istouch)

end

function module:wheelmoved(x, y)

end

function module:update(dt)

    -- limit delta as the end of day weigh-in can use up to .25 seconds
    -- causing a transition jump.
    self.transition:update(math.min(0.02, dt))

    if self.transition.isClosed then
        game.states:pop()
    end

end

function module:draw()

    -- save state
    love.graphics.push()

    -- underlay screenshot
    love.graphics.setColor(128, 128, 128)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("zoom")

    -- box fill
    love.graphics.setColor(game.color.white)
    love.graphics.rectangle("fill", self.left, self.top, self.width, self.height)

    -- draw icon
    love.graphics.push()
    love.graphics.translate(self.iconLeft, self.iconTop)
    love.graphics.setColor(game.color.blue)
    game.view.weather:drawIcon()
    love.graphics.pop()

    -- human readable forecast
    love.graphics.setFont(game.fonts.medium)
    love.graphics.setColor(game.color.yellow)
    love.graphics.printf(weather.forecast, self.left, self.readableTop, self.width, "center")

    -- details
    love.graphics.setColor(game.color.base00)
    love.graphics.draw(self.details, self.detailsLeft, self.detailsTop)

    -- icons
    love.graphics.push()
    love.graphics.translate(self.detailsLeft - iconSize, self.detailsTop)
    game.view.weather:drawThermometer()
    love.graphics.translate(0, game.fonts.mediumheight)
    game.view.weather:drawCloud()
    love.graphics.translate(0, game.fonts.mediumheight)
    game.view.weather:drawWind()
    love.graphics.pop()

    -- useful tips
    if weather.approachingfront then
        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(game.color.red)
        love.graphics.printf(hints.approaching, self.left, self.hintTop, self.width, "center")
    elseif weather.coldfront then
        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(game.color.blue)
        love.graphics.printf(hints.cold, self.left, self.hintTop, self.width, "center")
    elseif weather.postfrontal then
        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(game.color.cyan)
        love.graphics.printf(hints.postal, self.left, self.hintTop, self.width, "center")
    else
        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(game.color.green)
        love.graphics.printf(hints.other, self.left, self.hintTop, self.width, "center")
    end

    -- restore state
    love.graphics.pop()

end

return module
