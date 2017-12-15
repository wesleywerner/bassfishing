--[[
   bass fishing
   module.lua

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

    -- expect data to contain "title", "message" and optionally "shake bool".

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    -- save screen and use it as a menu background
    self.screenshot = data or love.graphics.newImage( love.graphics.newScreenshot() )

    -- load background image
    if not self.background then
        self.background = love.graphics.newImage("res/tackle-lures.png")
        self.backgroundY = self.height - self.background:getHeight()
        self.exitAbove = self.backgroundY
    end

    -- load lure sprites
    if not self.lures then
        self.lures = { }
        self.lures.image = love.graphics.newImage("res/lures spritesheet.png")
        self.lures.width = self.lures.image:getWidth()
        self.lures.height = self.lures.image:getHeight()
        local w, h = self.lures.width, self.lures.height

        -- the sprite size
        local sw, sh = 200, 160

        self.lures.quads = { }
        self.lures.quads["weed walker"] = love.graphics.newQuad(0, 1, sw, sh, w, h)
        self.lures.quads["torpedo"] = love.graphics.newQuad(0, 162, sw, sh, w, h)
        self.lures.quads["straight rapala"] = love.graphics.newQuad(0, 323, sw, sh, w, h)
        self.lures.quads["single blade spinbait"] = love.graphics.newQuad(0, 484, sw, sh, w, h)
        self.lures.quads["shad rapala"] = love.graphics.newQuad(0, 645, sw, sh, w, h)
        self.lures.quads["popper"] = love.graphics.newQuad(0, 806, sw, sh, w, h)
        self.lures.quads["paddle tail"] = love.graphics.newQuad(0, 967, sw, sh, w, h)
        self.lures.quads["meadow mouse"] = love.graphics.newQuad(0, 1128, sw, sh, w, h)
        self.lures.quads["lizard"] = love.graphics.newQuad(0, 1289, sw, sh, w, h)
        self.lures.quads["lil fishie"] = love.graphics.newQuad(0, 1450, sw, sh, w, h)
        self.lures.quads["jointed rapala"] = love.graphics.newQuad(0, 1611, sw, sh, w, h)
        self.lures.quads["jitterbug"] = love.graphics.newQuad(0, 1772, sw, sh, w, h)
        self.lures.quads["hula popper"] = love.graphics.newQuad(0, 1933, sw, sh, w, h)
        self.lures.quads["grub"] = love.graphics.newQuad(0, 2094, sw, sh, w, h)
        self.lures.quads["gator tail"] = love.graphics.newQuad(0, 2255, sw, sh, w, h)
        self.lures.quads["froggie"] = love.graphics.newQuad(0, 2416, sw, sh, w, h)
        self.lures.quads["fat rapala"] = love.graphics.newQuad(0, 2577, sw, sh, w, h)
        self.lures.quads["culprit worm"] = love.graphics.newQuad(0, 2738, sw, sh, w, h)
        self.lures.quads["crawfish"] = love.graphics.newQuad(0, 2899, sw, sh, w, h)
        self.lures.quads["beetle"] = love.graphics.newQuad(0, 3060, sw, sh, w, h)
        self.lures.quads["augertail worm"] = love.graphics.newQuad(0, 3221, sw, sh, w, h)
        self.lures.quads["double blade spinbait"] = love.graphics.newQuad(0, 3382, sw, sh, w, h)

        -- the total number of lure images, used to calculate the image list pages
        self.lures.number = 23

        -- perform a self-test that all lures have images
        if game.debug then
            for category, lurelist in pairs(game.logic.tackle.lures) do
                for _, lure in ipairs(lurelist) do
                    if not self.lures.quads[lure] then
                        game.dprint(string.format("WARNING: lure %q does not have an image", lure))
                    end
                end
            end
        end

    end

    -- state screen animation
    self.transition = game.view.screentransition:new(0.5, "inCubic")

    -- palette block size
    self.paletteSize = 40

    -- palette columns
    self.paletteColumns = 5

    -- spacing between printed rows
    self.linespacing = 30

    -- padding from the top
    self.topPadding = self.exitAbove + 20
    self.bottomPadding = 20
    self.leftPadding = 40

    -- list widths adjust to contents
    self.categoryListWidth = 0
    self.lureListWidth = 0

    -- list height fits the panel
    self.listHeight = self.height - self.topPadding - self.bottomPadding

    -- the font used for lists
    self.listFont = game.fonts.small

    -- pick the current lure color
    if game.logic.player.rod and game.logic.player.rod.lure then
        self.selectedColor = game.logic.player.rod.lure.color
    end

    -- default color
    if not self.selectedColor then
        self.selectedColor = "white"
    end

    -- make ordered list of categories
    if not self.categoryNames then

        self.categoryNames = { }

        for category, lures in pairs(game.logic.tackle.lures) do

            table.insert(self.categoryNames, category)

            -- measure the text and adjust the list width
            local textwidth = love.graphics.newText(self.listFont, category):getWidth()
            if self.categoryListWidth < textwidth then
                self.categoryListWidth = textwidth
            end

        end

        -- sort the list
        table.sort(self.categoryNames)

        -- make ordered list of lures
        self.lureNames = { }

        for category, lures in pairs(game.logic.tackle.lures) do

            self.lureNames[category] = lures

            -- sort the list
            table.sort(self.lureNames[category])

            -- measure the text and adjust the list width
            for _, text in ipairs(lures) do
                local textwidth = love.graphics.newText(self.listFont, text):getWidth()
                if self.lureListWidth < textwidth then
                    self.lureListWidth = textwidth
                end
            end

        end

    end

    -- height of font, used to center text
    local fontHeight = math.floor(love.graphics.newText(self.listFont, "ABC"):getHeight() / 2)

    -- create lure category list
    if not self.categoryList then

        -- aperture
        self.categoryList = game.lib.aperture:new{
            top = self.topPadding,
            left = self.leftPadding,
            width = self.categoryListWidth,
            height = self.listHeight,
            pages = 1,
        }

        -- hotspots
        for page, category in ipairs(self.categoryNames) do

            -- select default category
            if not self.selectedCategory then
                self.selectedCategory = category
            end

            self.categoryList:insert(
                game.lib.hotspot:new{
                    top = (self.linespacing * (page - 1)),
                    left = 0,
                    width = self.categoryListWidth,
                    height = self.linespacing,
                    textY = (self.linespacing / 2) - fontHeight,
                    category = category,
                    page = page,
                    action = function(hotspot)
                        self.selectedCategory = hotspot.category
                        self.lureList:scrollTo(hotspot.page)
                        end
                    }
            )

        end

    end

    -- create lure list
    if not self.lureList then

        -- aperture
        self.lureList = game.lib.aperture:new{
            top = self.topPadding,
            left = self.leftPadding * 2 + self.categoryListWidth,
            width = self.lureListWidth,
            height = self.listHeight,
            pages = #self.categoryList.hotspots,
        }

        -- hotspots
        for page, category in ipairs(self.categoryNames) do

            for n, lure in ipairs(self.lureNames[category]) do

                -- select default lure
                if not self.selectedLure then
                    self:selectLure(lure)
                end

                self.lureList:insert(
                    game.lib.hotspot:new{
                        top = ((page - 1) * self.listHeight) + (self.linespacing * (n - 1)),
                        left = 0,
                        width = self.lureListWidth,
                        height = self.linespacing,
                        textY = (self.linespacing / 2) - fontHeight,
                        lure = lure,
                        action = function(hotspot)
                            self:selectLure(hotspot.lure)
                            end
                        }
                )

            end

        end

    end

    -- create color palette
    if not self.palette then

        -- aperture
        self.palette = game.lib.aperture:new{
            top = self.topPadding,
            -- right align palette on screen
            left = self.width - self.lures.width - self.leftPadding,
            -- width of the lure image
            width = self.lures.width,
            height = self.listHeight,
            pages = 1,
        }

        -- color palette
        local column = 0
        local row = 0
        for color, data in pairs(game.logic.tackle.colors) do

            self.palette:insert(
                game.lib.hotspot:new{
                    top = (self.paletteSize * row),
                    left = (self.paletteSize * column),
                    width = self.paletteSize,
                    height = self.paletteSize,
                    color = color,
                    action = function(hotspot)
                        self:setLure()
                        end
                }
            )

            column = column + 1

            if column == self.paletteColumns then
                column = 0
                row = row + 1
            end

        end

    end

    -- create fish image list
    if not self.imageList then

        -- aperture
        self.imageList = game.lib.aperture:new{
            top = self.palette.top + 100,
            left = self.palette.left,
            width = self.lures.width,
            height = self.lures.height,
            pages = self.lures.number,
        }

        -- hotspots
        local n = 0
        for key, quad in pairs(self.lures.quads) do
            self.imageList:insert(
                game.lib.hotspot:new{
                    top = n * self.lures.height,
                    left = 0,
                    width = self.lures.width,
                    height = self.lures.height,
                    quad = quad
                }
            )
            n = n + 1
        end

    end

    -- if the player has no rod selected, show the rod selection
    if not game.logic.player.rod then
        game.states:push("tackle rods")
    end

end

function module:keypressed(key)

    if key == "escape" then

        self.transition:close(0.5, "outBack")

    end

end

function module:mousemoved( x, y, dx, dy, istouch )

    self.categoryList:mousemoved( x, y, dx, dy, istouch )

    self.lureList:mousemoved( x, y, dx, dy, istouch )

    self.palette:mousemoved( x, y, dx, dy, istouch )

    -- draw in hovered color
    for _, hotspot in ipairs(self.palette.hotspots) do
        if hotspot.touched then
            self.selectedColor = hotspot.color
        end
    end

end

function module:mousepressed( x, y, button, istouch )

    if y < self.exitAbove then

        self.transition:close(0.5, "outBack")

    end

    self.categoryList:mousepressed( x, y, button, istouch )

    self.lureList:mousepressed( x, y, button, istouch )

    self.palette:mousepressed( x, y, button, istouch )

end

function module:selectLure(lure)

    self.selectedLure = lure

    self.lureImageQuad = self.lures.quads[lure]

    game.dprint("selected lure", lure)

end

function module:update(dt)

    self.categoryList:update(dt)

    self.lureList:update(dt)

    -- update main transition
    self.transition:update(dt)

    -- exit this state if mainn transition is closed
    if self.transition.isClosed then
        game.states:pop()
    end

end

function module:draw()

    -- save screen state
    love.graphics.push()

    -- underlay screenshot
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(self.screenshot)

    -- apply transform
    self.transition:apply("slide up")

    -- tackle background
    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.background, 0, self.backgroundY)

    -- draw the list of lure categories
    love.graphics.setFont(self.listFont)
    self.categoryList:apply()
    for _, hotspot in ipairs(self.categoryList.hotspots) do
        if hotspot.category == self.selectedCategory then
            -- selected focus
            love.graphics.setColor(game.color.base3)
            love.graphics.rectangle("fill", 0, hotspot.top, hotspot.width, hotspot.height)
            love.graphics.setColor(game.color.magenta)
        elseif hotspot.touched then
            -- hover focus
            love.graphics.setColor(game.color.base3)
            love.graphics.rectangle("line", hotspot.left, hotspot.top, hotspot.width, hotspot.height)
            love.graphics.setColor(game.color.magenta)
        else
            -- normal
            love.graphics.setColor(game.color.base01)
        end
        love.graphics.print(hotspot.category, hotspot.left, hotspot.top + hotspot.textY)
    end
    self.categoryList:release()

    -- draw the list of lures
    love.graphics.setFont(self.listFont)
    self.lureList:apply()
    for _, hotspot in ipairs(self.lureList.hotspots) do
        if hotspot.lure == self.selectedLure then
            -- selected focus
            love.graphics.setColor(game.color.base3)
            love.graphics.rectangle("fill", 0, hotspot.top, hotspot.width, hotspot.height)
            love.graphics.setColor(game.color.magenta)
        elseif hotspot.touched then
            -- hover focus
            love.graphics.setColor(game.color.base3)
            love.graphics.rectangle("line", hotspot.left, hotspot.top, hotspot.width, hotspot.height)
            love.graphics.setColor(game.color.magenta)
        else
            -- normal
            love.graphics.setColor(game.color.base01)
        end
        love.graphics.print(hotspot.lure, hotspot.left, hotspot.top + hotspot.textY)
    end
    self.lureList:release()

    -- palette
    self.palette:apply()
    for _, hotspot in ipairs(self.palette.hotspots) do
        love.graphics.setColor(game.logic.tackle.colors[hotspot.color])
        love.graphics.rectangle("fill", hotspot.left, hotspot.top, self.paletteSize, self.paletteSize)
        -- selected color focus
        if hotspot.touched or hotspot.color == self.selectedColor then
            love.graphics.setColor(game.color.base01)
        else
            love.graphics.setColor(game.color.base3)
        end
        love.graphics.rectangle("line", hotspot.left, hotspot.top,
            self.paletteSize - 1, self.paletteSize - 1)
    end
    self.palette:release()

    -- lure images
    if self.lureImageQuad then
        self.imageList:apply()
        love.graphics.setColor(game.logic.tackle.colors[self.selectedColor])
        love.graphics.draw(self.lures.image, self.lureImageQuad, 0, 0)
        self.imageList:release()
    end

    -- restore screen state
    love.graphics.pop()

end

function module:setLure()

    game.dprint("setting lure", self.selectedColor, self.selectedLure)

    -- set the player lure
    game.logic.player:setLure(self.selectedCategory, self.selectedLure, self.selectedColor)

    -- begin the screen close animation
    module.transition:close(0.5, "outBack")

end

return module
