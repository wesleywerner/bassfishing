--[[
   tournament.lua

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
local scale = 2
local buttons = nil
local maphotspot = nil

function module:init(data)

    -- save callback when we exit this state
    self.callback = data.callback

    love.graphics.origin()

    -- generate a random lake (for testing this state without lake selection)
    if not game.lake then
        data = { practice = false }
        local seed = 42
        game.lake = game.logic.genie:generate(game.defaultMapWidth,
        game.defaultMapHeight, seed,
        game.defaultMapDensity, game.defaultMapIterations)
    end

    -- prepare the lake
    game.logic.genie:populateLakeWithFishAndBoats(game.lake)
    game.logic.boat:prepare(game.logic.player)
    game.logic.boat:launchBoat(game.logic.player)

    -- create mini map
    self.minimap = game.view.maprender:renderMini()

    -- clear live well
    game.logic.livewell:empty()

    -- add player boat to the boats list so it can be included in obstacle tests
    table.insert(game.lake.boats, game.logic.player)

    -- load the camera
    game.lib.camera:worldSize(
        game.lake.width * game.view.tiles.size * scale,
        game.lake.height * game.view.tiles.size * scale)

    -- set camera lens size
    game.lib.camera:frame(6, 6, 613, 588)

    -- center the camera
    game.lib.camera:instant(-game.lake.width * game.view.tiles.size / 2, -game.lake.height * game.view.tiles.size / 2)

    -- load the game border
    if not self.borderImage then
        self.borderImage = love.graphics.newImage("res/tournament-border.png")
    end

    -- set up the buttons
    if not buttons then
        self:makeButtons()
    end

    -- fill the fish finder with data
    game.view.fishfinder:update()

    self.practice = data.practice

    if self.practice then
        -- change the weather
        game.logic.weather:change()
        -- disable tournament functions
        game.logic.tournament:disable()
    else
        -- begin the tournament
        game.logic.tournament:start()
    end

    game.music:play("tournament")

end

function module:keypressed(key)
    if key == "escape" then
        self:promptExitTournament()
    elseif key == "left" or key == "kp4" or key == "a" then
        game.logic.player:left()
        game.view.fishfinder:update()
    elseif key == "right" or key == "kp6" or key == "d" then
        game.logic.player:right()
        game.view.fishfinder:update()
    elseif key == "up" or key == "kp8" or key == "w" then
        if game.logic.player:forward() then
            game.view.fishfinder:update()
        end
    elseif key == "down" or key == "kp2" or key == "s" then
        if game.logic.player:reverse() then
            game.view.fishfinder:update()
        end
    elseif key == "r" then
        game.states:push("tackle rods")
    elseif key == "l" then
        game.states:push("tackle lures")
    elseif key == "m" then
        game.states:push("map")
    elseif key == "f8" then
        game.states:push("top lunkers")
    elseif key == "t" then
        buttons:get("motor"):callback()
    elseif key == "f" then
        game.states:push("weather forecast")
    elseif key == "v" then
        game.states:push("live well")
    else
        buttons:keypressed(key)
    end

    -- debug shortcuts
    if game.debug then
        if key == "f1" then
            game.logic.tournament:takeTime(15)
        elseif key == "f10" then
            game.states:push("lakegen development")
        elseif key == "f9" then
            game.logic.tournament:endOfDay()
        elseif key == "f3" then
            game.logic.weather:change()
        elseif key == "space" then
            game.view.notify:add(string.format("%s this is a test notifications",
            os.date("%c", os.time())), math.random() < 0.1)
        end
    end

end

function module:mousemoved(x, y, dx, dy, istouch)

    -- move over buttons
    buttons:mousemoved(x, y, dx, dy, istouch)
    maphotspot:mousemoved(x, y, dx, dy, istouch)

    -- set status text to a button tip
    statustext = nil
    for _, btn in pairs(buttons.controls) do
        if btn.focused then
            statustext = btn.hint
        end
    end

    -- translate the point relative to the camera frame
    x, y = game.lib.camera:pointToFrame(x, y)

    -- aim the cast
    if x and y then
        game.logic.player:aimCast( x / scale, y / scale )
    end

end

function module:mousepressed(x, y, button, istouch)

    -- press on buttons
    buttons:mousepressed(x, y, button, istouch)
    maphotspot:mousepressed(x, y, button, istouch)

    -- translate the point relative to the camera frame
    x, y = game.lib.camera:pointToFrame(x, y)

    if x and y then

        game.view.fishfinder:update()

        -- account for the camera scale
        x = math.floor(x / scale)
        y = math.floor(y / scale)

        -- convert screen to map coordinates
        x = 1 + math.floor(x / game.view.tiles.size)
        y = 1 + math.floor(y / game.view.tiles.size)

        -- test if the position is past cast range
        if game.logic.player:aimPastRange(x, y) then
            game.logic.player:moveTowardsPoint(x, y)
        else
            game.logic.player:cast()
        end

    end

end

function module:mousereleased(x, y, button, istouch)

    -- release over buttons
    buttons:mousereleased(x, y, button, istouch)
    maphotspot:mousereleased(x, y, button, istouch)

end

function module:update(dt)

    game.logic.competitors:update(dt)

    game.logic.player:update(dt)

    if not self.practice then

        -- check if the tournament is finished
        if game.logic.tournament.day == 4 then
            self:exitState()
        end

        -- check if the day is over
        if game.logic.tournament.time == 0 then
            game.view.notify:clear()
            game.sound:stop("outboard")
            game.logic.tournament:endOfDay()
        end

        -- if near the jetty end the day
        if game.logic.tournament.displayedWarning
        and game.logic.player.nearJetty
        and game.logic.player.speed == 0 then
            game.view.notify:clear()
            game.sound:stop("outboard")
            game.logic.tournament:endOfDay()
        end

    end

    -- update buttons
    buttons:update(dt)

    -- update fish movement animations
    if game.debug then game.logic.fish:update(dt) end

    game.lib.camera:center(game.logic.player.screenX * scale, game.logic.player.screenY * scale)
    game.lib.camera:update(dt)

    -- update notifications
    game.view.notify:update(dt)

end

function module:draw()

    -- must render the map outside any transformations
    game.view.maprender:render()
    game.view.fishfinder:render()

    -- pose the camera, all drawings are relative to the frame.
    game.lib.camera:pose()

    -- draw the map
    love.graphics.setColor(255, 255, 255)
    love.graphics.scale(scale, scale)
    love.graphics.draw(game.view.maprender.image)

    -- draw fish (debugging)
    if game.debug then game.view.fish:draw() end

    -- draw other boats
    game.view.competitors:draw()

    -- draw player boat
    game.view.player:draw()

    game.lib.camera:relax()

    -- draw notifications
    game.view.notify:draw()

    -- draw game border
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.borderImage)

    -- draw buttons
    buttons:draw()

    -- fish finder
    love.graphics.push()
    love.graphics.translate(634, 433)
    game.view.fishfinder:draw()
    love.graphics.pop()

    if not self.practice then
        love.graphics.push()
        love.graphics.translate(634, 14)
        game.view.clock:draw()
        love.graphics.pop()
    end

    -- weather icon
    love.graphics.push()
    love.graphics.translate(680, 32)
    love.graphics.setColor(game.color.base2)
    game.view.weather:drawIcon()
    love.graphics.pop()

    -- print status line
    if statustext then
        love.graphics.push()
        love.graphics.translate(10, 570)
        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(game.color.white)
        love.graphics.print(statustext)
        love.graphics.pop()
    elseif game.logic.player.speed > 0 and not game.logic.player.trolling then
        -- boat speed
        love.graphics.push()
        love.graphics.translate(10, 570)
        game.view.player.printBoatSpeed()
        love.graphics.pop()
    else
        -- rod and lure selection
        love.graphics.push()
        love.graphics.translate(20, 570)
        game.view.player:drawRodDetails()
        love.graphics.pop()
    end

    -- mini map
    love.graphics.push()
    love.graphics.translate(634, 371)
    love.graphics.scale(1.8, 1.8)
    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.minimap)

    -- player position on the mini map
    love.graphics.scale(1, 1)
    love.graphics.translate(-1, -1)
    love.graphics.rectangle("fill", game.logic.player.x, game.logic.player.y, 2, 2)
    love.graphics.pop()

    -- mini map border
    love.graphics.setColor(game.color.blue)
    love.graphics.rectangle("line", 634, 371, 150, 56)

end

function module:exitState()

    game.sound:stop("outboard")
    game.music:play("menu")
    game.states:pop()

    -- fire the callback to refresh player stats
    -- (received from the main menu state via lake selection)
    if type(self.callback) == "function" then
        self.callback()
    end

end

function module:promptExitTournament()

    if self.practice then
        self:exitState()
    else
        local data = {
            message = "Are you sure you want to exit the tournament? [Y/N]",
            prompt = true,
            callback = function()
                self:exitState()
                end
        }
        game.states:push("messagebox", data)
    end

end

function module:makeButtons()

    local width = 130
    local spacing = 40
    local left = 643
    local top = 90
    love.graphics.setFont(game.fonts.small)
    buttons = game.lib.widgetCollection:new()

    game.view.ui:setButton(
        buttons:button("forecast", {
            left = left,
            top = top,
            text = "Forecast",
            hint = "Weather forecast (f)",
            callback = function(btn)
                game.states:push("weather forecast")
                end
        }), width
    )

    top = top + spacing
    game.view.ui:setSwitch(
        buttons:button("motor", {
            left = left,
            top = top,
            text = "motor",
            hint = "Switch between outboard and trolling (t)",
            callback = function(btn)
                -- take time switching motors
                game.logic.tournament:takeTime(1)
                game.logic.player:toggleTrollingMotor()
                end
        }), {"Outboard", "Trolling"}, width
    )

    top = top + spacing
    game.view.ui:setButton(
        buttons:button("lures", {
            left = left,
            top = top,
            text = "Lures",
            hint = "Pick a lure (l)",
            callback = function(btn)
                game.states:push("tackle lures")
                end
        }), width
    )

    top = top + spacing
    game.view.ui:setButton(
        buttons:button("rods", {
            left = left,
            top = top,
            text = "Rods",
            hint = "Pick a rod (r)",
            callback = function(btn)
                game.states:push("tackle rods")
                end
        }), width
    )

    top = top + spacing
    game.view.ui:setButton(
        buttons:button("livewell", {
            left = left,
            top = top,
            hint = "Look inside your live well (v)",
            text = "Live well",
            callback = function(btn)
                game.states:push("live well")
                end
        }), width
    )

    -- create hotspots (buttons without interface)
    maphotspot = game.lib.hotspot:new{
        left = 634,
        top = 371,
        width = 150,
        height = 56,
        hint = "Look at the map (m)",
        callback = function()
            game.sound:play("select")
            game.states:push("map")
            end
    }

end

return module
