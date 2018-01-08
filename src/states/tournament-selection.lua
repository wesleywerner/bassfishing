--[[
   bass fishing
   main-menu.lua

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

function module:init(data)

    -- flag if the tournament should start upon state close
    self.startTournament = false

    -- save screen and use it as a menu background
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

    -- buttons
    self.buttons = self:makeButtons()

    -- screen animation
    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

    -- lake list
    if not self.lakelist then
        local llst = game.lib.list:new()
        self.lakelist = llst
        llst.font = game.fonts.medium
        llst.itemHeight = game.fonts.mediumheight
        llst.textColor = game.color.blue
        llst.fillColor = game.color.blue
        llst.selectedColor = game.color.base3
        llst.left = 10
        llst.top = 100
        llst.width = 300
        llst.height = game.window.height / 2 --- self.lakelist.top
        llst:add("Buttermere")
        llst:add("Cabora Bassa Lake")
        llst:add("Lake Sagara")
        llst:add("Lake Vida")
        llst:add("Lake Van")
        llst:add("Lough Neagh")
        llst:add("Lake Garda")
        llst:add("Lake Ladoga")
        llst:add("Loch Ness")
        llst:add("Midlands Reservoir")
        llst:add("Pete's Pond")
    end

    -- render first map
    self:newMap(self:seedFromString(self.lakelist:selectedItem()))

end

function module:keypressed(key)

    if key == "escape" then
        self.transition:close(game.transition.time, game.transition.exit)
    elseif key == "up" then
        self.lakelist:selectPrev()
        self:newMap(self:seedFromString(self.lakelist:selectedItem()))
    elseif key == "down" then
        self.lakelist:selectNext()
        self:newMap(self:seedFromString(self.lakelist:selectedItem()))
    else
        self.buttons:keypressed(key)
    end

end

function module:mousemoved(x, y, dx, dy, istouch)

    self.buttons:mousemoved(x, y, dx, dy, istouch)

end

function module:mousepressed(x, y, button, istouch)

    self.buttons:mousepressed(x, y, button, istouch)

end

function module:mousereleased(x, y, button, istouch)

    self.buttons:mousereleased(x, y, button, istouch)

    if self.lakelist:selectPoint(x - self.lakelist.left, y - self.lakelist.top) then
        self:newMap(self:seedFromString(self.lakelist:selectedItem()))
    end

end

function module:wheelmoved(x, y)

    if y > 0 then
        self.lakelist:selectPrev()
    else
        self.lakelist:selectNext()
    end

    self:newMap(self:seedFromString(self.lakelist:selectedItem()))

end

function module:update(dt)

    self.buttons:update(dt)

    -- limit delta as the end of day weigh-in can use up to .25 seconds
    -- causing a transition jump.
    self.transition:update(math.min(0.02, dt))

    if self.transition.isClosed then
        game.states:pop()
        if self.startTournament then
            game.states:push("tournament", { practice = false })
        end
    end

end

function module:draw()

    -- cache the lake preview to canvas: has to render outside any transforms
    if not self.lakepreview then
        self.lakepreview = game.view.maprender.renderMini()
    end

    -- underlay screenshot
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("drop down")

    -- menu background
    love.graphics.setColor(game.color.base2)
    love.graphics.rectangle("fill", 0, 0, game.window.width, game.window.height)

    -- buttons
    self.buttons:draw()

    love.graphics.setColor(game.color.base0)
    love.graphics.printf("Enter a 3-day tournament.\nYour biggest fish are entered into the record books.", 0, 40, game.window.width, "center")

    -- lake list
    love.graphics.setColor(game.color.base01)
    love.graphics.push()
    love.graphics.translate(self.lakelist.left, self.lakelist.top)
    self.lakelist:draw()
    love.graphics.pop()

    -- scale the map to fit
    love.graphics.push()
    love.graphics.translate(350, 100)
    love.graphics.scale(5, 5)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.lakepreview, 0, 0)
    love.graphics.pop()

end

function module:seedFromString(name)

    local seed = 0
    local len = string.len(name)
    for i=1, len do
        seed = seed + string.byte(name, i)
    end
    return seed

end

function module:newMap(seed)

    game.lake = game.logic.genie:generate(game.defaultMapWidth,
    game.defaultMapHeight, seed,
    game.defaultMapDensity, game.defaultMapIterations)

    -- clear the map canvas so it redraws itself
    module.lakepreview = nil

end

function module:play()

    -- generate a random lake
    --if self.panel.page == 2 then
        --local seed = os.time()
        --game.dprint(string.format("generating practice map with seed %d", seed))
        --self:newMap(seed)
        --game.states:push("tournament", { practice = true })
    --else

    -- set lake name on tournament start
    self.startTournament = true
    game.logic.player.lake = self.lakelist:selectedItem()
    game.dprint(string.format("\nSelected lake %q", game.logic.player.lake))
    self:keypressed("escape")

end

function module:makeButtons()

    local collection = game.lib.widgetCollection:new()

    -- Launch boat
    game.view.ui:setButton(
        collection:button("launch", {
            left = 60,
            top = game.window.height - 60,
            text = "Launch boat",
            callback = function(btn)
                self:play()
                end
        })
    )

    -- Back
    game.view.ui:setButton(
        collection:button("back", {
            left = game.window.width - 100,
            top = game.window.height - 60,
            text = "Back",
            callback = function(btn)
                self:keypressed("escape")
                end
        })
    )

    return collection

end

return module
