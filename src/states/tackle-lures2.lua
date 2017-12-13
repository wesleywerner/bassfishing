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
    self.screenshot = love.graphics.newImage( love.graphics.newScreenshot() )

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
    self.screenTransition = game.view.screentransition:new(1, "outCubic")

    -- palette block size
    self.colorSize = 50

    -- spacing between printed rows
    self.linespacing = 30

    -- padding from the top
    self.topPadding = self.exitAbove + 20
    self.bottomPadding = 20
    self.leftPadding = 20
    self.listWidth = 200    -- 3 lists with 20 px padding
    self.listHeight = self.height - self.topPadding - self.bottomPadding

    ---- default color
    if not self.selectedColor then
        self.selectedColor = "white"
    end

    -- make ordered list of categories
    if not self.categoryNames then

        self.categoryNames = { }

        for category, lures in pairs(game.logic.tackle.lures) do

            table.insert(self.categoryNames, category)

        end

        -- sort the list
        table.sort(self.categoryNames)

        -- make ordered list of lures
        self.lureNames = { }

        for category, lures in pairs(game.logic.tackle.lures) do

            self.lureNames[category] = lures

            -- sort the list
            table.sort(self.lureNames[category])

        end

    end

    -- create lure category list
    if not self.categoryList then

        -- aperture
        self.categoryList = game.lib.aperture:new{
            top = self.topPadding,
            left = self.leftPadding,
            width = self.listWidth,
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
                    width = self.listWidth,
                    height = self.linespacing,
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
            left = self.leftPadding * 2 + self.listWidth,
            width = self.listWidth,
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
                        width = self.listWidth,
                        height = self.linespacing,
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
            left = self.leftPadding * 3 + self.listWidth * 2,
            width = self.listWidth,
            height = self.listHeight,
            pages = 1,
        }

        -- color palette
        local column = 0
        local row = 0
        for color, data in pairs(game.logic.tackle.colors) do

            self.palette:insert(
                game.lib.hotspot:new{
                    top = (self.colorSize * row),
                    left = (self.colorSize * column),
                    width = self.colorSize,
                    height = self.colorSize,
                    color = color,
                    action = function(hotspot)
                        self:setLure()
                        end
                }
            )

            column = column + 1

            if column > 4 then
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

        self.screenTransition:close(0.5, "outBack")

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

        self.screenTransition:close(0.5, "outBack")

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
    self.screenTransition:update(dt)

    -- exit this state if mainn transition is closed
    if self.screenTransition.isClosed then
        game.states:pop()
    end

end

function module:draw()

    -- save screen state
    love.graphics.push()

    -- underlay screenshot
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(self.screenshot)

    -- apply screen transform
    love.graphics.translate(0, self.backgroundY - (self.backgroundY * self.screenTransition.scale))

    -- tackle background
    love.graphics.setColor(game.color.white)
    love.graphics.draw(self.background, 0, self.backgroundY)

    -- categories
    love.graphics.setFont(game.fonts.small)
    self.categoryList:apply()
    for _, hotspot in ipairs(self.categoryList.hotspots) do
        if hotspot.touched or hotspot.category == self.selectedCategory then
            love.graphics.setColor(game.color.magenta)
        else
            love.graphics.setColor(game.color.base01)
        end
        love.graphics.print(hotspot.category, hotspot.left, hotspot.top)
    end
    self.categoryList:release()

    -- lures
    love.graphics.setFont(game.fonts.small)
    self.lureList:apply()
    for _, hotspot in ipairs(self.lureList.hotspots) do
        if hotspot.touched or hotspot.lure == self.selectedLure then
            love.graphics.setColor(game.color.magenta)
        else
            love.graphics.setColor(game.color.base01)
        end
        love.graphics.print(hotspot.lure, hotspot.left, hotspot.top)
    end
    self.lureList:release()

    -- palette
    self.palette:apply()
    for _, hotspot in ipairs(self.palette.hotspots) do
        love.graphics.setColor(game.logic.tackle.colors[hotspot.color])
        love.graphics.rectangle("fill", hotspot.left, hotspot.top, self.colorSize, self.colorSize)
        -- selected color focus
        if hotspot.touched or hotspot.color == self.selectedColor then
            love.graphics.setColor(game.color.base01)
        else
            love.graphics.setColor(game.color.base3)
        end
        love.graphics.rectangle("line", hotspot.left, hotspot.top, self.colorSize, self.colorSize)
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
    module.screenTransition:close(0.5, "outBack")

end

return module
