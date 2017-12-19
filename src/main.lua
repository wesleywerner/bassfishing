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

-- TODO: create a imperial/metric conversion and apply it:
-- * fish on messages
-- * live well
-- * weigh-in results
-- * tournament results
-- * top lunkers
-- * weather conditions
-- * rename rod line tests (light, medium, heavy)

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

    love.window.setMode(game.window.width, game.window.height)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    --game.states:add("lake selection", require("states.lake-selection"))

    game.states:add("main menu", require("states.main-menu"))
    game.states:add("tournament", require("states.tournament"))
    game.states:add("messagebox", require("states.messagebox"))
    game.states:add("lakegen development", require("states.lakegen-development"))
    game.states:add("weigh in", require("states.weigh-in"))
    game.states:add("tournament results", require("states.tournament-results"))
    game.states:add("tackle rods", require("states.tackle-rods"))
    game.states:add("tackle lures", require("states.tackle-lures"))
    game.states:add("map", require("states.map"))
    game.states:add("top lunkers", require("states.top-lunkers"))
    game.states:add("text entry", require("states.text-entry"))

    game.logic.toplunkers:load()

end

function love.update(dt)

    game.states:update(dt)

end

function love.keypressed(key)

    game.states:keypressed(key)

    -- save a screenshot
    if key == "f12" then
        savescreen()
    end

end

function love.mousemoved(x, y, dx, dy, istouch)

    game.states:mousemoved(x, y, dx, dy, istouch)

end

function love.mousepressed(x, y, button, istouch)

    game.states:mousepressed(x, y, button, istouch)

end

function love.wheelmoved(x, y)

    game.states:wheelmoved(x, y)

end

function love.draw()

    game.states:draw()

end

function love.textinput(text)

    game.states:textinput(text)

end
