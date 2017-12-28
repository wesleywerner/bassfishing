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

-- the total number of anglers that can register
local maxAnglers = 6
local iconsLeft = 170
local iconTop = 120
local iconColumns = 3
local iconPadding = 36

--- State initialization.
--
-- @tparam table data
-- Additional data passed to the the state during push.
function module:init(data)

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    -- save screen and use it as a menu background
    --self.screenshot = love.graphics.newImage(love.graphics.newScreenshot())

    self.transition = game.view.screentransition:new(1, "outBack")

    -- sign in icons
    self.icons = love.graphics.newImage("res/sign-in-icons.png")
    self:loadAnglers()
    self:buildButtons()

    -- flags when an angler was selected
    self.anglerSelected = false

end

function module:loadAnglers()

    self.anglers = { }

    for _, angler in ipairs(game.logic.anglers.data) do
        table.insert(self.anglers, { name=angler.name, icon=#self.anglers + 2 })
    end

    table.insert(self.anglers, { name="New Angler", icon=1, addNew=true })

    -- keyboard navigation focus
    self.keyfocus = 1
    self.anglers[self.keyfocus].focus = true

end

--- Builds the angler login buttons
function module:buildButtons()

    local spritesW, spritesH = self.icons:getDimensions()

    -- add icon quads and positions
    local iconWidth = 144
    local iconHeight = 150
    local iconX = iconsLeft
    local iconY = iconTop
    local column = 1

    for id, angler in ipairs(self.anglers) do

        -- remove "add new" if maximum reached
        if #self.anglers > maxAnglers and angler.addNew then
            table.remove(self.anglers, id)
        else

            angler.quad = love.graphics.newQuad(
                (angler.icon - 1) * iconWidth, 0,   -- x, y
                iconWidth, iconHeight,   -- width, height
                spritesW, spritesH) -- sprite sheet size

            angler.left = iconX
            angler.top = iconY
            angler.width = iconWidth
            angler.height = iconHeight
            angler.hitX = angler.left + angler.width
            angler.hitY = angler.top + angler.height

            iconX = iconX + iconWidth + iconPadding

            column = column + 1
            if column > iconColumns then
                iconX = iconsLeft
                column = 1
                iconY = iconY + iconHeight + iconPadding
            end

        end

    end

end

function module:newAnglerInput(value)

    if value:len() == 0 then return end
    game.logic.anglers:addAngler(value)
    self:loadAnglers()
    self:buildButtons()

end

function module:keypressed(key)

    if key == "escape" then
        self.transition:close(1, "inBack")
    elseif key == "left" then
        self.keyfocus = math.max(1, self.keyfocus - 1)
        self:updateFocus()
    elseif key == "right" then
        self.keyfocus = math.min(#self.anglers, self.keyfocus + 1)
        self:updateFocus()
    elseif key == "return" then
        self:selectFocused()
    end

end

function module:mousemoved(x, y, dx, dy, istouch)

    -- focus angler buttons
    for i, angler in ipairs(self.anglers) do

        -- focus
        local hitX = x > angler.left and x < angler.hitX
        local hitY = y > angler.top and y < angler.hitY
        angler.focus = hitX and hitY

        -- sync keyboard focus
        if angler.focus then
            self.keyfocus = i
        end

    end

end

function module:mousepressed(x, y, button, istouch)

end

function module:mousereleased(x, y, button, istouch)

    self:selectFocused()
    for i, angler in ipairs(self.anglers) do

        if angler.focus then
            if angler.addNew then
                -- new angler
                game.states:push("text entry", {
                    text="",
                    title="Angler's name:",
                    callback=function(text)
                        self:newAnglerInput(text)
                    end
                    })
            else
                game.dprint(string.format("\nselected angler %q", angler.name))
                game.logic.stats:load(angler.name)
                game.logic.player.name = game.logic.stats.data.name
                self.transition:close(1, "inBack")
            end
        end

    end

end

function module:update(dt)

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

end

function module:draw()

    -- save state
    love.graphics.push()

    -- underlay screenshot
    --love.graphics.setColor(game.color.white)
    --love.graphics.draw(self.screenshot)

    -- apply transform
    -- "center zoom", "slide up", "drop down", "drop up"
    self.transition:apply("drop down")

    -- background
    love.graphics.clear(game.color.base03)

    -- title
    love.graphics.setColor(game.color.yellow)
    love.graphics.setFont(game.fonts.large)
    love.graphics.printf("angler sign-in", 0, 20, self.width, "center")

    -- anglers
    love.graphics.setColor(game.color.white)
    love.graphics.setFont(game.fonts.medium)
    for i, angler in ipairs(self.anglers) do

        -- draw angler icon
        love.graphics.setColor(game.color.white)
        love.graphics.draw(self.icons, angler.quad, angler.left, angler.top)

        -- focus
        if angler.focus or i == self.keyfocus then
            love.graphics.setColor(game.color.blue)
        else
            love.graphics.setColor(game.color.base2)
        end

        -- print angler name
        love.graphics.printf(angler.name, angler.left + 10, angler.top + 10,
            angler.width - 20, "center")

    end

    -- restore state
    love.graphics.pop()

end

function module:updateFocus()

    for i, angler in ipairs(self.anglers) do
        angler.focus = i == self.keyfocus
    end

end

function module:selectFocused()

    for i, angler in ipairs(self.anglers) do

        if angler.focus then
            if angler.addNew then
                -- new angler
                game.states:push("text entry", {
                    text="",
                    title="Angler's name:",
                    callback=function(text)
                        self:newAnglerInput(text)
                    end
                    })
            else
                game.dprint(string.format("\nselected angler %q", angler.name))
                game.logic.stats:load(angler.name)
                game.logic.player.name = game.logic.stats.data.name
                self.anglerSelected = true
                self.transition:close(1, "inBack")
            end
        end

    end

end

return module
