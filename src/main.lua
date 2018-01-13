--[[
   main.lua

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

-- TODO: write release process & versioning

game = require("game")

function savescreen()

    local screenshot = love.graphics.newScreenshot()
    local dir = love.filesystem.getSaveDirectory()
    local counter = 0
    local filename = nil

    repeat
        counter = counter + 1
        filename = string.format("screenshot_%.3d.png", counter)
    until not love.filesystem.exists( filename )

    screenshot:encode('png', filename)
    print(string.format("saved %s/%s", dir, filename))

end

function love.load()

    game.dprint(string.format("Running bass lover version %s", game.version))

    love.window.setMode(game.window.width, game.window.height)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    game.logic.toplunkers:load()

    -- load and apply saved options
    game.logic.options:load()
    game.lib.convert.metric = game.logic.options.data.metric

    game.logic.anglers:load()
    game.states:add("tournament", require("states.tournament"))
    game.states:add("sign-in", require("states.sign-in"))
    game.states:add("main menu", require("states.main-menu"))
    --game.states:add("tournament", require("states.tournament"))
    game.states:add("tournament selection", require("states.tournament-selection"))
    game.states:add("messagebox", require("states.messagebox"))
    game.states:add("lakegen development", require("states.lakegen-development"))
    game.states:add("weigh in", require("states.weigh-in"))
    game.states:add("tournament results", require("states.tournament-results"))
    game.states:add("tackle rods", require("states.tackle-rods"))
    game.states:add("tackle lures", require("states.tackle-lures"))
    game.states:add("map", require("states.map"))
    game.states:add("top lunkers", require("states.top-lunkers"))
    game.states:add("text entry", require("states.text-entry"))
    game.states:add("weather forecast", require("states.weather-forecast"))
    game.states:add("live well", require("states.live-well"))
    game.states:add("options", require("states.options"))


    game.music:play("menu")

end

function love.update(dt)

    game.states:update(dt)
    game.music:update(dt)

end

function love.keypressed(key)

    -- save a screenshot
    if key == "f12" then
        savescreen()
    elseif key == "f2" then
        game.lib.convert.metric = not game.lib.convert.metric
    else
        game.states:keypressed(key)
    end

end

function love.mousemoved(x, y, dx, dy, istouch)

    game.states:mousemoved(x, y, dx, dy, istouch)

end

function love.mousepressed(x, y, button, istouch)

    game.states:mousepressed(x, y, button, istouch)

end

function love.mousereleased(x, y, button, istouch)

    game.states:mousereleased(x, y, button, istouch)

end

function love.wheelmoved(x, y)

    game.states:wheelmoved(x, y)

end

function love.draw()

    game.states:draw()

end
