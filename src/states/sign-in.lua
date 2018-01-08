--[[
   bass fishing
   sign-in.lua

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

--- Provides a screen to sign-in as an existing angler, or to register
-- a new angler.
--
-- @module sign-in

local module = { }

-- stores list of sign-in buttons
local collection = { }

-- load the sign-in icons
local icons = love.graphics.newImage("res/sign-in-icons.png")
local fishimage = love.graphics.newImage("res/johnny-automatic-jumping-fish-300px.png")

-- Set icons and spritesheet size
local spritesW, spritesH = icons:getDimensions()
local iconWidth = 144
local iconHeight = 150

-- number of available icon variations
local iconVariations = 6

-- horizontal padding between angler buttons
local padding = 40

-- Id of the selected button
local selectedId = 1

-- Animating carousel offsets
local previousCarouselX = 0
local carouselX = 0
local carouselY = 200
local carouselCenter = 300
local carouselScale = 0

--- State initialization.
--
-- @tparam table data
-- Additional data passed to the the state during push.
function module:init(data)

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    -- center fish image
    local fishimgW, fishimgH = fishimage:getDimensions()
    self.fishimageX = (self.width - fishimgW) / 2
    self.fishimageY = (self.height - fishimgH) / 2

    self.transition = game.view.screentransition:new(game.transition.time, game.transition.enter)

    -- add a new angler option
    love.graphics.setFont(game.fonts.small)
    self.newButton = game.lib.button:new{
        top = self.height - 60,
        left = self.width - 160,
        text = "New Angler",
        callback = function()
            game.states:push("text entry", {
                text="",
                title="Angler's name:",
                callback=function(text)
                    self:newAnglerInput(text)
                end
                })
            end
    }
    game.view.ui:setButton(self.newButton)

    -- sign in icons
    self:buildButtons()

end

-- a nice lerping function
local function lerp(a, b, amt)
    return a + (b - a) * (amt < 0 and 0 or (amt > 1 and 1 or amt))
end

local function drawSigninButton(btn)

    love.graphics.push()

    if btn.Id == selectedId then
        love.graphics.setColor(255, 255, 255, carouselScale * 255)
    else
        love.graphics.setColor(255, 255, 255, 92)
    end

    love.graphics.draw(icons, btn.quad, btn.left, btn.top)

    -- print angler name
    love.graphics.setFont(game.fonts.medium)
    love.graphics.printf(btn.name, btn.left + 10, btn.top + 10,
        btn.width - 20, "center")

    love.graphics.pop()

end

--- Builds the angler login buttons
function module:buildButtons(autoselectname)

    collection = { }

    -- build list of anglers
    for anglerId, angler in ipairs(game.logic.anglers.data) do
        table.insert(collection, {
            name = angler.name
        })
    end

    -- order alphabetically
    table.sort(collection, function(a, b) return a.name < b.name end)

    -- set the button data
    for anglerId, button in ipairs(collection) do

        -- auto select this button
        if button.name == autoselectname then
            selectedId = anglerId
        end

        button.Id = anglerId
        button.top = 0
        button.left = (iconWidth + padding) * (anglerId - 1)
        button.width = iconWidth
        button.height = iconHeight
        button.draw = drawSigninButton
        button.update = function() end

        -- the button icon quad
        local iconIndex = math.max(1, anglerId % iconVariations)
        button.quad = love.graphics.newQuad(
            iconIndex * iconWidth, 0,   -- x, y
            iconWidth, iconHeight,   -- width, height
            spritesW, spritesH) -- sprite sheet size

    end

end

function module:newAnglerInput(value)

    if value:len() == 0 then return end
    game.logic.anglers:addAngler(value)
    self:buildButtons(value)

end

function module:keypressed(key)

    if key == "escape" then
        self.transition:close(game.transition.time, game.transition.exit)
    elseif key == "left" then
        self:carouselLeft()
    elseif key == "right" then
        self:carouselRight()
    elseif key == "return" then
        self:signIn()
    end

end

function module:carouselLeft()

    local newid = math.max(1, selectedId - 1)
    if newid ~= selectedId then
        selectedId = newid
        previousCarouselX = carouselX
        carouselScale = 0
    end

end

function module:carouselRight()

    local newid = math.min(#collection, selectedId + 1)
    if newid ~= selectedId then
        selectedId = newid
        previousCarouselX = carouselX
        carouselScale = 0
    end

end

function module:mousemoved(x, y, dx, dy, istouch)

    self.newButton:mousemoved(x, y, dx, dy, istouch)

end

function module:mousepressed(x, y, button, istouch)

    self.newButton:mousepressed(x, y, button, istouch)

end

function module:mousereleased(x, y, button, istouch)

    self.newButton:mousereleased(x, y, button, istouch)

    -- move the carousel
    if y > carouselY and y < (carouselY + iconHeight) then
        if x > (carouselCenter + iconWidth) then
            self:carouselRight()
        elseif x < (carouselCenter) then
            self:carouselLeft()
        elseif x > carouselCenter and x < (carouselCenter + iconWidth) then
            self:signIn()
        end
    end

end

function module:wheelmoved(x, y)

    if y > 0 then
        self:carouselLeft()
    else
        self:carouselRight()
    end

end

function module:update(dt)

    self.newButton:update(dt)

    -- limit delta as the end of day weigh-in can use up to .25 seconds
    -- causing a transition jump.
    self.transition:update(math.min(0.02, dt))

    if self.transition.isClosed then

        -- close this sign-in state
        game.states:pop()

        -- begin the menu state
        if self.anglerSelected then
            game.states:push("main menu")
        end

    end

    -- update button scaling animation
    for _, v in ipairs(collection) do
        v:update(dt)
    end

    -- upate carousel sliding animation
    local targetX = carouselCenter - (selectedId - 1) * (iconWidth + padding)
    carouselScale = math.min(1, carouselScale + (dt * 4))
    carouselX = lerp(previousCarouselX, targetX, carouselScale)

end

function module:draw()

    love.graphics.clear(game.color.base01)

    -- save state
    love.graphics.push()

    -- apply transform
    -- "center zoom", "slide up", "drop down", "drop up"
    self.transition:apply("drop down")

    -- background
    love.graphics.draw(game.border)

    -- fish image
    love.graphics.setColor(255, 255, 255, 192)
    love.graphics.draw(fishimage, self.fishimageX, self.fishimageY)

    -- title
    love.graphics.setColor(game.color.blue)
    love.graphics.setFont(game.fonts.large)
    love.graphics.printf(game.title, 0, 10, self.width, "center")

    -- sub title
    love.graphics.setColor(game.color.yellow)
    love.graphics.setFont(game.fonts.medium)
    love.graphics.printf("angler sign-in", 0, 80, self.width, "center")

    -- draw sign-in button carousel
    love.graphics.push()
    love.graphics.translate(carouselX, carouselY)
    for _, v in ipairs(collection) do
        v:draw()
    end
    love.graphics.pop()

    self.newButton:draw()

    -- restore state
    love.graphics.pop()

end

function module:updateFocus()

    for i, angler in ipairs(self.anglers) do
        angler.focus = i == self.keyfocus
    end

end

function module:signIn()

    if #collection == 0 then return end
    local anglername = collection[selectedId].name
    game.dprint(string.format("\nselected angler %q", anglername))
    game.logic.stats:load(anglername)
    game.logic.player.name = game.logic.stats.data.name
    self.anglerSelected = true
    self.transition:close(game.transition.time, game.transition.exit)

end

return module
