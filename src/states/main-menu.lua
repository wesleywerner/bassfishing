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

-- available charts
local chartTypes = {
    {
        key="weigh-in",
        text="total weighed-in"
    },
    {
        key="heaviest",
        text="heaviest fish"
    }
}

function module:init(data)

    -- load menu background
    self.background = love.graphics.newImage("res/main-menu.png")

    -- stats text object
    self.statsText = self:makeStatsText()

    -- buttons
    self.buttons = self:makeButtons()

    -- chart
    self.chart = game.view.ui:chart(chartWidth, chartHeight)

    -- overwrite chart node drawing
    self.chart.drawNode = function (chart, dataset, node)
        love.graphics.setColor(game.color.blue)
        if node.focus then
            love.graphics.setColor(game.color.magenta)
            love.graphics.circle("fill", node.x, node.y, 6)
            -- tooltip size
            local tip = chart.tips[node.a]
            local tipwidth, tipheight = tip:getDimensions()
            -- offset tooltip from the cursor
            love.graphics.push()
            love.graphics.translate(math.floor(-tipwidth * .5), 20)
            -- tooltip fill (with padding)
            local pad1, pad2 = 5, 10
            love.graphics.setColor(game.color.base02)
            love.graphics.rectangle("fill", node.x - pad1, node.y - pad1,
                tipwidth + pad2, tipheight + pad2)
            -- outline
            love.graphics.setColor(game.color.base2)
            love.graphics.rectangle("line", node.x - pad1, node.y - pad1,
                tipwidth + pad2, tipheight + pad2)
            -- print tip text
            love.graphics.setColor(game.color.white)
            love.graphics.draw(tip, math.floor(node.x), math.floor(node.y))
            love.graphics.pop()
        else
            love.graphics.circle("fill", node.x, node.y, 6)
        end
    end

    -- set chart data
    self.chartType = 1
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
    love.graphics.print(game.logic.stats.data.name, 105, 42)

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
    love.graphics.printf(chartTypes[self.chartType].text, 0, 0, chartWidth, "right")
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

    local stats = game.logic.stats.data
    local left = 0
    local top = 0
    local width = 220
    local spacing = 20

    local w, h = love.graphics.newText(game.fonts.tiny, "BASS"):getDimensions()
    local text = love.graphics.newText(game.fonts.tiny)

    local stats = {
        {
            label="Tournaments fished:",
            value=#stats.tours
        },
        {
            label="Fish weighed:",
            value=string.format("%d fish, %s", stats.total.fish, game.lib.convert:weight(stats.total.weight))
        },
        {
            label="Heaviest ever caught:",
            value=game.lib.convert:weight(stats.total.heaviest)
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

function module:setChartData()

    -- alias the stats
    local stats = game.logic.stats.data

    -- get the chart type
    local chartType = chartTypes[self.chartType]

    -- clear the chart
    self.chart:clear()

    if chartType.key == "weigh-in" then

        -- total fish weighed-in per tournament
        local points = { }
        self.chart.tips = { }

        for n, tour in ipairs(stats.tours) do

            -- insert the data points
            table.insert(points, { a=n, b=tour.totalWeight })

            -- pre-create each point tooltip
            local tourdate = os.date("%d %b %Y", tour.date)
            local weight = game.lib.convert:weight(tour.totalWeight)
            local tiptext = love.graphics.newText(game.fonts.tiny)
            tiptext:add(string.format("%s\n%s", tourdate, weight, 0, 0))
            self.chart.tips[n] = tiptext

        end

        self.chart:data(points, "weigh-in")

    elseif chartType.key == "heaviest" then

        -- heaviest fish caught per tournament
        local points = { }
        self.chart.tips = { }

        for n, tour in ipairs(stats.tours) do

            -- find the heaviest catch in this tournament
            local lunker = 0
            for _, fish in ipairs(tour.fish) do
                if fish.weight > lunker then
                    lunker = fish.weight
                end
            end

            -- insert the data points
            table.insert(points, { a=n, b=lunker })

            -- pre-create each point tooltip
            local tourdate = os.date("%d %b %Y", tour.date)
            local weight = game.lib.convert:weight(lunker)
            local tiptext = love.graphics.newText(game.fonts.tiny)
            tiptext:add(string.format("%s\n%s", tourdate, weight, 0, 0))
            self.chart.tips[n] = tiptext

        end

        self.chart:data(points, "heaviest")

    end

end


function module:makeButtons()

    local top = 300
    local left = 600
    local width, height = 150, 40
    local collection = game.lib.widgetCollection:new()

    -- Tournament mode
    game.view.ui:setButton(
        collection:button("tournament", {
            left = left,
            top = top,
            text = "Tournament",
            callback = function(btn)
                -- TODO: go to lake selection state
                end
        }), width
    )

    -- Education mode
    top = top + height
    game.view.ui:setButton(
        collection:button("educational", {
            left = left,
            top = top,
            text = "Educational",
            callback = function(btn)
                -- TODO: go to educational state + map generator
                end
        }), width
    )

    -- Tutorial
    top = top + height
    game.view.ui:setButton(
        collection:button("tutorial", {
            left = left,
            top = top,
            text = "Tutorial",
            callback = function(btn)
                local seed = os.time()
                game.dprint(string.format("generating practice map with seed %d", seed))
                game.lake = game.logic.genie:generate(game.defaultMapWidth,
                game.defaultMapHeight, seed,
                game.defaultMapDensity, game.defaultMapIterations)
                game.states:push("tournament", { tutorial = true })
                end
        }), width
    )

    -- Game options
    top = top + height
    game.view.ui:setButton(
        collection:button("options", {
            left = left,
            top = top,
            text = "Options",
            callback = function(btn)
                -- TODO: go to options state
                end
        }), width
    )

    -- Top lunkers
    top = top + height
    game.view.ui:setButton(
        collection:button("records", {
            left = left,
            top = top,
            text = "Records",
            callback = function(btn)
                game.states:push("top lunkers")
                end
        }), width
    )

    -- About game
    top = top + height
    game.view.ui:setButton(
        collection:button("about", {
            left = left,
            top = top,
            text = "About",
            callback = function(btn)
                -- TODO: go to about state
                end
        }), width
    )

    -- chart left
    game.view.ui:setButton(
        collection:button("chart right", {
            left = chartX,
            top = chartY + chartHeight + 20,
            text = ">",
            callback = function(btn)
                if self.chartType < #chartTypes then
                    self.chartType = math.min(#chartTypes, self.chartType + 1)
                else
                    self.chartType = 1
                end
                self:setChartData()
            end
        })
    )

    return collection

end

return module
