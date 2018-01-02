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

local chartX, chartY = 50, 300
local chartWidth, chartHeight = 445, 215

function module:init(data)

    -- load menu background
    self.background = love.graphics.newImage("res/main-menu.png")

    -- stats text object
    self.statsText = self:makeStatsText()

    -- buttons
    self.buttons = game.view.ui:createMainMenuButtons()

    -- chart
    self.chart = game.view.ui:chart(chartWidth, chartHeight)
    self:setChartData()


    ---- toggle for metric vs imperial values
    --game.lib.convert.metric = not game.lib.convert.metric

    --table.insert(self.hotspots, newButton("Records", 450, hotspotY,
        --{ action = function() game.states:push("top lunkers") end }))

    --table.insert(self.hotspots, newButton("Launch boat!", 570, hotspotY,
        --{ action = function() self:play() end }))

    --self.panel = game.lib.aperture:new{
        --top = 130,
        --left = 40,
        --width = self.width - 80,
        --height = 330,
        --pages = 2,
        --landscape = true
    --}

    ---- lake list relative to the panel
    --self.lakelist = game.lib.list:new()
    --self.lakelist.left = 1
    --self.lakelist.top = 60
    --self.lakelist.width = 220
    --self.lakelist.height = self.panel.height - self.lakelist.top - 1
    --self.lakelist.itemHeight = love.graphics.newText(game.fonts.small, "BASS"):getHeight()
    --self.lakelist:add("Buttermere")
    --self.lakelist:add("Cabora Bassa Lake")
    --self.lakelist:add("Lake Sagara")
    --self.lakelist:add("Lake Vida")
    --self.lakelist:add("Lake Van")
    --self.lakelist:add("Lough Neagh")
    --self.lakelist:add("Lake Garda")
    --self.lakelist:add("Lake Ladoga")
    --self.lakelist:add("Loch Ness")
    --self.lakelist:add("Midlands Reservoir")
    --self.lakelist:add("Pete's Pond")

    ---- lake list item draw callback
    --function self.lakelist.drawItem(id, item, selected)
        --local py = (id - 1) * self.lakelist.itemHeight
        --local px = 10
        --if selected then
            --love.graphics.setColor(game.color.magenta)
            --love.graphics.rectangle("fill", 0, py, 220, 20)
            --love.graphics.setColor(game.color.base3)
        --else
            --love.graphics.setColor(game.color.base01)
        --end
        --love.graphics.print(item, px, py)
    --end

    -- measure font size
    --self.smallFontHeight = love.graphics.newText(game.fonts.small, "BASS"):getHeight()

    ---- calback to set the player name
    --local nameInputAction = function()
        --game.states:push("text entry", {
            --text = game.logic.player.name,
            --callback = function(text)
                --game.logic.player.name = text
                --end
            --})
    --end

    ---- player name
    --self.nameinput = game.lib.hotspot:new{
        --top = self.lakelist.top,
        --left = 230,
        --width = 480,
        --height = 34,
        --textY = (34 - self.smallFontHeight) / 2,
        --action = nameInputAction
    --}
    --self.panel:insert(self.nameinput)

    ---- render first map
    --self:newMap(self:seedFromString(self.lakelist:selectedItem()))

end

function module:keypressed(key)

    if key == "escape" then
        game.states:pop()
    --elseif key == "up" then
        --self.lakelist:selectPrev()
        --self:newMap(self:seedFromString(self.lakelist:selectedItem()))
    --elseif key == "down" then
        --self.lakelist:selectNext()
        --self:newMap(self:seedFromString(self.lakelist:selectedItem()))
    --elseif key == "left" then
        --self.panel:scrollTo(1)
    --elseif key == "right" then
        --self.panel:scrollTo(2)
    --elseif key == "return" then
        --self:play()
    else
        self.buttons:keypressed(key)
    end

end

function module:mousemoved(x, y, dx, dy, istouch)

    self.buttons:mousemoved(x, y, dx, dy, istouch)
    self.chart:mousemoved(x - chartX, y - chartY, dx, dy, istouch)

end

function module:mousepressed(x, y, button, istouch)

    self.buttons:mousepressed(x, y, button, istouch)

    --for _, hotspot in ipairs(self.hotspots) do
        --if hotspot.focused then
            --if hotspot.page then
                --self.panel:scrollTo(hotspot.page)
            --else
                --hotspot:action()
            --end
        --end
    --end

    ---- lake list selection
    --if self.panel.page == 1 then

        --local px, py = self.panel:pointFromScreen(x, y)

        ---- within list bounds
        --if px > 0 and px < self.lakelist.width then

            --py = py - self.lakelist.top
            --local i = math.ceil(py / self.lakelist.itemHeight)

            ---- within bounds
            --if i > 0 and i <= #self.lakelist.contents then

                --self.lakelist:selectIndex(i)

                ---- render the mini map
                --self:newMap(self:seedFromString(self.lakelist:selectedItem()))

            --end

        --end

    --end

    ---- panel clicks
    --self.panel:mousepressed(x, y, button, istouch)

end

function module:mousereleased(x, y, button, istouch)

    self.buttons:mousereleased(x, y, button, istouch)

end

function module:wheelmoved(x, y)

    --if y > 0 then
        --self.panel:scrollTo(1)
    --else
        --self.panel:scrollTo(2)
    --end

end

function module:update(dt)

    self.buttons:update(dt)
    self.chart:update(dt)

end

function module:draw()

    -- cache the lake preview to canvas: has to render outside any transforms
    --if not self.lakepreview then
        --self.lakepreview = game.view.maprender.renderMini()
    --end

    -- menu background
    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.background, 0, 0)

    -- angler name
    love.graphics.setFont(game.fonts.medium)
    love.graphics.setColor(game.color.base01)
    love.graphics.print(game.stats.name, 105, 42)

    -- stats
    love.graphics.setFont(game.fonts.small)
    love.graphics.setColor(game.color.base01)
    love.graphics.draw(self.statsText, 105, 76)

    -- buttons
    self.buttons:draw()

    -- chart
    love.graphics.push()
    love.graphics.translate(chartX, chartY)
    self.chart:draw()
    love.graphics.translate(0, -24)
    love.graphics.setColor(game.color.cyan)
    love.graphics.setFont(game.fonts.small)
    love.graphics.printf("fish weighed per tour", 0, 0, chartWidth, "right")
    love.graphics.pop()

    -- tournament slug
    --love.graphics.printf("3 day tournament:\nyou are eligible to be entered into the big fish record books", 0, 0, self.panel.width, "center")

    -- lake list box
    --love.graphics.setColor(game.color.base3)
    --love.graphics.rectangle("fill", self.lakelist.left, self.lakelist.top,
        --self.lakelist.width, self.lakelist.height)
    --love.graphics.setColor(game.color.base1)
    --love.graphics.rectangle("line", self.lakelist.left, self.lakelist.top,
        --self.lakelist.width, self.lakelist.height)

    -- lake list items
    --love.graphics.setFont(game.fonts.small)
    --love.graphics.setColor(game.color.base01)
    --love.graphics.push()
    --love.graphics.translate(0, self.lakelist.top)
    --self.lakelist:draw()
    --love.graphics.pop()

    -- scale the map to fit
    --love.graphics.push()
    --love.graphics.translate(self.lakelist.width + 10, 150)
    --love.graphics.scale(6, 6)
    --love.graphics.setColor(255, 255, 255)
    --love.graphics.draw(self.lakepreview, 0, 0)
    --love.graphics.pop()

    -- practice mode text
    --love.graphics.printf("practice fishing:\nfish a random lake without any time limit or weigh-in.", 0, 0, self.panel.width, "center")

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
    --module.lakepreview = nil

end

function module:play()

    ---- generate a random lake
    --if self.panel.page == 2 then
        --local seed = os.time()
        --game.dprint(string.format("generating practice map with seed %d", seed))
        --self:newMap(seed)
        --game.states:push("tournament", { practice = true })
    --else
        ---- set lake name on tournament start
        --game.logic.player.lake = self.lakelist:selectedItem()
        --game.dprint(string.format("\nSelected lake %q", game.logic.player.lake))
        --game.states:push("tournament", { practice = false })
    --end

end

function module:makeStatsText()

    local left = 0
    local top = 0
    local width = 220
    local spacing = 20

    local w, h = love.graphics.newText(game.fonts.small, "BASS"):getDimensions()
    local text = love.graphics.newText(game.fonts.small)

    local stats = {
        {
            label="Tournaments fished:",
            value=100
        },
        {
            label="Fish weighed:",
            value="300 fish, " .. game.lib.convert:weight(500)
        },
        {
            label="Largest fish:",
            value=game.lib.convert:weight(5) .. ", in Wes's Pond"
        },
        {
            label="Most effective lure:",
            value="chartreuse straight rapala"
        }
    }

    for n, stat in ipairs(stats) do

        -- label
        text:addf(stat.label, width, "right", left, top + (n - 1) * h)

        -- value
        text:add(stat.value, left + width + spacing, top + (n - 1) * h)

    end

    return text

end

function module:setChartData(name)

    local points = { }

    for n=1, 10 do
        table.insert(points, { a=n, b=math.random(20, 90) })
    end

    self.chart:data(points, "dataset")

end

return module
