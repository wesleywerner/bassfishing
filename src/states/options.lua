--[[
   options.lua
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
local buttons = nil
local alphabet = "abcdefghijklmnopqrstuvwxyz"
local debugtrigger = "ilovebass"
local triggerinput = ""

function module:init(data)

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage(love.graphics.newScreenshot())

    self:makeButtons()

    -- screen transition
    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

end

function module:keypressed(key)

    if key == "escape" then
        game.logic.options:save()
        self.transition:close(game.transition.time, game.transition.exit)
    else
        buttons:keypressed(key)
    end

    -- listen for debug trigger
    if alphabet:find(key) then

        -- returns true if input matches start of trigger
        local function testmatch()
            return string.sub(debugtrigger, 1, string.len(triggerinput)) == triggerinput
        end

        -- add to trigger input when it matches
        if testmatch() then

            triggerinput = triggerinput..key

            if triggerinput == debugtrigger then
                self:makeDebugButton()
            end

        else
            -- reset when no match
            triggerinput = key
        end

    end

end

function module:mousemoved(x, y, dx, dy, istouch)

    -- move over buttons
    buttons:mousemoved(x, y, dx, dy, istouch)

end

function module:mousepressed(x, y, button, istouch)

    -- press on buttons
    buttons:mousepressed(x, y, button, istouch)

end

function module:mousereleased(x, y, button, istouch)

    -- release over buttons
    buttons:mousereleased(x, y, button, istouch)

end

function module:update(dt)

    -- limit delta as the end of day weigh-in can use up to .25 seconds
    -- causing a transition jump.
    self.transition:update(math.min(0.02, dt))

    if self.transition.isClosed then
        -- release screenshot
        self.screenshot = nil
        -- exit this state
        game.states:pop()
    end

    -- update buttons
    buttons:update(dt)

end

function module:draw()

    -- save state
    love.graphics.push()

    -- underlay screenshot
    local fade = 255 - (128 * self.transition.scale)
    love.graphics.setColor(fade, fade, fade)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("zoom")

    -- background
    love.graphics.setColor(game.color.white)
    love.graphics.draw(game.border)

    -- title
    love.graphics.setFont(game.fonts.large)
    love.graphics.setColor(game.color.darktext)
    love.graphics.printf("Options", 0, 60, game.window.width, "center")

    -- draw buttons
    love.graphics.setFont(game.fonts.small)
    buttons:draw()

    -- button labels
    love.graphics.setColor(game.color.darktext)
    for _, btn in pairs(buttons.controls) do
        if btn.label then
            love.graphics.print(btn.label, 40, btn.top)
        end
    end

    -- restore state
    love.graphics.pop()

end

function module:makeButtons()

    -- buttons already created
    if buttons then return end

    local spacing = 40
    local left = 300
    local top = 100
    love.graphics.setFont(game.fonts.small)
    buttons = game.lib.widgetCollection:new()

    top = top + spacing
    game.view.ui:setSwitch(
        buttons:button("measurement", {
            left = left,
            top = top,
            text = "motor",
            label = "Units of measure",
            callback = function(btn)
                game.lib.convert.metric = not game.lib.convert.metric
                game.logic.options.data.metric = game.lib.convert.metric
                game.dprint(string.format("set measurement option metric %s", tostring(game.lib.convert.metric)))
                end
        }), {"Metric", "Imperial"}
    )

    -- set the value for measurement switch (it defaults to metric at first)
    if not game.lib.convert.metric then
        buttons:get("measurement"):setOption(2)
    end

    -- Done button
    game.view.ui:setButton(
        buttons:button("done", {
            left = game.window.width - 100,
            top = game.window.height - 60,
            text = "Done",
            callback = function(btn)
                self:keypressed("escape")
                end
        })
    )

end

function module:makeDebugButton()

    if not buttons:get("debug") then

        game.view.ui:setSwitch(
            buttons:button("debug", {
                left = 200,
                top = game.window.height - 60,
                text = "debug",
                label = "Debug mode",
                callback = function(btn)
                    game.debug = not game.debug
                    game.dprint("debug mode enabled")
                    end
            }), {"Off", "On"}
        )

        -- flip switch if already in debug mode
        if game.debug then
            buttons:get("debug"):setOption(2)
        end

    end

end

return module
