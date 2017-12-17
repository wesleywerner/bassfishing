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

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    self.background = love.graphics.newImage("res/main-menu.png")

    self.hotspots = { }

    table.insert(self.hotspots, game.lib.hotspot:new{
        top = 550,
        left = 40,
        width = love.graphics.newText(game.fonts.medium, "Tournament"):getWidth(),
        height = 22,
        text = "Tournament",
        page = 1
    })

    table.insert(self.hotspots, game.lib.hotspot:new{
        top = 550,
        left = 230,
        width = love.graphics.newText(game.fonts.medium, "Practice"):getWidth(),
        height = 22,
        text = "Practice",
        page = 2
    })

    table.insert(self.hotspots, game.lib.hotspot:new{
        top = 550,
        left = 600,
        width = love.graphics.newText(game.fonts.medium, "Launch boat!"):getWidth(),
        height = 22,
        text = "Launch boat!",
    })

    self.panel = game.lib.aperture:new{
        top = 130,
        left = 40,
        width = self.width - 80,
        height = 330,
        pages = 2,
        landscape = true
    }

    -- lake list relative to the panel
    self.lakelist = game.lib.list:new()
    self.lakelist.left = 1
    self.lakelist.top = 60
    self.lakelist.width = 220
    self.lakelist.height = self.panel.height - self.lakelist.top - 1
    self.lakelist.itemHeight = love.graphics.newText(game.fonts.small, "BASS"):getHeight()
    self.lakelist:add("Buttermere")
    self.lakelist:add("Cabora Bassa Lake")
    self.lakelist:add("Lake Sagara")
    self.lakelist:add("Lake Vida")
    self.lakelist:add("Lake Van")
    self.lakelist:add("Lough Neagh")
    self.lakelist:add("Lake Garda")
    self.lakelist:add("Lake Ladoga")
    self.lakelist:add("Loch Ness")
    self.lakelist:add("Midlands Reservoir")
    self.lakelist:add("Pete's Pond")

    -- lake list item draw callback
    function self.lakelist.drawItem(id, item, selected)
        local py = (id - 1) * self.lakelist.itemHeight
        local px = 10
        if selected then
            love.graphics.setColor(game.color.magenta)
            love.graphics.rectangle("fill", 0, py, 220, 20)
            love.graphics.setColor(game.color.base3)
        else
            love.graphics.setColor(game.color.base01)
        end
        love.graphics.print(item, px, py)
    end

    -- measure font size
    self.smallFontHeight = love.graphics.newText(game.fonts.small, "BASS"):getHeight()

    -- calback to set the player name
    local nameInputAction = function()
        game.states:push("text entry", {
            text = game.logic.player.name,
            callback = function(text)
                game.logic.player.name = text
                end
            })
    end

    -- player name
    self.nameinput = game.lib.hotspot:new{
        top = self.lakelist.top,
        left = 230,
        width = 480,
        height = 34,
        textY = (34 - self.smallFontHeight) / 2,
        action = nameInputAction
    }
    self.panel:insert(self.nameinput)

    -- render first map
    self:newMap(self:seedFromString(self.lakelist:selectedItem()))

end

function module:keypressed(key)

    if key == "escape" then
        game.states:pop()
    elseif key == "up" then
        self.lakelist:selectPrev()
        self:newMap(self:seedFromString(self.lakelist:selectedItem()))
    elseif key == "down" then
        self.lakelist:selectNext()
        self:newMap(self:seedFromString(self.lakelist:selectedItem()))
    elseif key == "left" then
        self.panel:scrollTo(1)
    elseif key == "right" then
        self.panel:scrollTo(2)
    elseif key == "return" then
        self:play()
    end

end

function module:mousemoved(x, y, dx, dy, istouch)

    for _, hotspot in ipairs(self.hotspots) do
        hotspot:mousemoved(x, y, dx, dy, istouch)
    end

    self.panel:mousemoved(x, y, dx, dy, istouch)

end

function module:mousepressed(x, y, button, istouch)

    for _, hotspot in ipairs(self.hotspots) do
        if hotspot.touched then
            if hotspot.page then
                self.panel:scrollTo(hotspot.page)
            else
                self:play()
            end
        end
    end

    -- lake list selection
    if self.panel.page == 1 then

        local px, py = self.panel:pointFromScreen(x, y)

        -- within list bounds
        if px > 0 and px < self.lakelist.width then

            py = py - self.lakelist.top
            local i = math.ceil(py / self.lakelist.itemHeight)

            -- within bounds
            if i > 0 and i <= #self.lakelist.contents then

                self.lakelist:selectIndex(i)

                -- render the mini map
                self:newMap(self:seedFromString(self.lakelist:selectedItem()))

            end

        end

    end

    -- panel clicks
    self.panel:mousepressed(x, y, button, istouch)

end

function module:wheelmoved(x, y)

    if y > 0 then
        self.panel:scrollTo(1)
    else
        self.panel:scrollTo(2)
    end

end

function module:update(dt)

    self.panel:update(dt)

end

function module:draw()

    -- cache the lake preview to canvas
    -- has to render outside any transforms
    if not self.lakepreview then
        self.lakepreview = game.view.maprender.renderMini()
    end

    -- menu background
    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.background, 0, 0)

    -- title
    love.graphics.setFont(game.fonts.large)
    love.graphics.setColor(game.color.blue)
    love.graphics.printf("Bass Fishing", 0, 30, self.width, "center")
    love.graphics.draw(game.view.tiles.image, game.view.tiles.fish.large, 190, 30)

    -- game mode hotspots
    love.graphics.setFont(game.fonts.medium)
    for _, hotspot in ipairs(self.hotspots) do
        if hotspot.touched or self.panel.page == hotspot.page then
            love.graphics.setColor(game.color.magenta)
            love.graphics.rectangle("fill", hotspot.left, hotspot.top,
                hotspot.width, hotspot.height)
            love.graphics.setColor(game.color.base3)
        else
            love.graphics.setColor(game.color.base1)
            love.graphics.rectangle("line", hotspot.left, hotspot.top,
                hotspot.width, hotspot.height)
            love.graphics.setColor(game.color.base01)
        end
        love.graphics.printf(hotspot.text, hotspot.left, hotspot.top, hotspot.width, "center")
    end

    -- enter panel mode
    self.panel:apply()

    -- tournament slug
    love.graphics.setFont(game.fonts.small)
    love.graphics.setColor(game.color.blue)
    love.graphics.printf("3 day tournament:\nyou are eligible to be entered into the big fish record books", 0, 0, self.panel.width, "center")

    -- lake list box
    love.graphics.setColor(game.color.base3)
    love.graphics.rectangle("fill", self.lakelist.left, self.lakelist.top,
        self.lakelist.width, self.lakelist.height)
    love.graphics.setColor(game.color.base1)
    love.graphics.rectangle("line", self.lakelist.left, self.lakelist.top,
        self.lakelist.width, self.lakelist.height)

    -- lake list items
    love.graphics.setFont(game.fonts.small)
    love.graphics.setColor(game.color.base01)
    love.graphics.push()
    love.graphics.translate(0, self.lakelist.top)
    self.lakelist:draw()
    love.graphics.pop()

    -- scale the map to fit
    love.graphics.push()
    love.graphics.translate(self.lakelist.width + 10, 150)
    love.graphics.scale(6, 6)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.lakepreview, 0, 0)
    --love.graphics.setColor(game.color.violet)
    --love.graphics.rectangle("line", 0, 0, game.lake.width, game.lake.height)
    love.graphics.pop()

    -- player name
    love.graphics.push()
    love.graphics.translate(self.nameinput.left, self.nameinput.top)
    -- fill
    love.graphics.setColor(game.color.base3)
    love.graphics.rectangle("fill", 0, 0, self.nameinput.width, self.nameinput.height)
    -- border
    love.graphics.setColor(game.color.base1)
    love.graphics.rectangle("line", 0, 0, self.nameinput.width, self.nameinput.height)
    -- text
    love.graphics.setFont(game.fonts.small)
    love.graphics.setColor(game.color.base01)
    love.graphics.printf(string.format("Your name: %s", game.logic.player.name),
        10, self.nameinput.textY, self.nameinput.width)
    love.graphics.pop()

    -- practice mode text
    love.graphics.push()
    love.graphics.translate(self.panel.width, 0)
    love.graphics.setFont(game.fonts.small)
    love.graphics.setColor(game.color.blue)
    love.graphics.printf("practice fishing:\nfish a random lake without any time limit or weigh-in.", 0, 0, self.panel.width, "center")
    love.graphics.pop()

    self.panel:release()

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
    if self.panel.page == 2 then
        local seed = os.time()
        game.dprint(string.format("generating practice map with seed %d", seed))
        self:newMap(seed)
    end

    game.states:push("tournament")

end

return module
