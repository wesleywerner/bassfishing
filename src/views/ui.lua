--[[
   bass fishing
   ui.lua

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

-- button image is a cut-up of edges and fill
local image = love.graphics.newImage("res/button.png")
local imw, imh = image:getDimensions()

-- define the quads that make up the button parts
local quad = { }
quad.left = love.graphics.newQuad(0, 0, 15, 32, imw, imh)
quad.fill = love.graphics.newQuad(30, 0, 1, 32, imw, imh)
quad.right = love.graphics.newQuad(136, 0, 15, 32, imw, imh)

-- button hover
quad.focused = { }
quad.focused.left = love.graphics.newQuad(0, 39, 15, 32, imw, imh)
quad.focused.fill = love.graphics.newQuad(30, 39, 1, 32, imw, imh)
quad.focused.right = love.graphics.newQuad(136, 39, 15, 32, imw, imh)

-- button down
quad.down = { }
quad.down.left = love.graphics.newQuad(0, 76, 15, 32, imw, imh)
quad.down.fill = love.graphics.newQuad(30, 76, 1, 32, imw, imh)
quad.down.right = love.graphics.newQuad(136, 76, 15, 32, imw, imh)

-- switch quads
quad.switch = { }
quad.switch.left = love.graphics.newQuad(0, 112, 15, 32, imw, imh)
quad.switch.fill = love.graphics.newQuad(30, 112, 1, 32, imw, imh)
quad.switch.right = love.graphics.newQuad(136, 112, 15, 32, imw, imh)
quad.switch.button = love.graphics.newQuad(60, 112, 30, 32, imw, imh)

quad.switch.focused = { }
quad.switch.focused.left = love.graphics.newQuad(0, 151, 15, 32, imw, imh)
quad.switch.focused.fill = love.graphics.newQuad(30, 151, 1, 32, imw, imh)
quad.switch.focused.right = love.graphics.newQuad(136, 151, 15, 32, imw, imh)
quad.switch.focused.button = love.graphics.newQuad(60, 151, 30, 32, imw, imh)

-- a nice lerping function
local function lerp(a, b, amt)
    return a + (b - a) * (amt < 0 and 0 or (amt > 1 and 1 or amt))
end

--- Draw callback for buttons
function module.drawButton(btn)

    -- this is a very unoptimized but functional demonstration.
    -- a better way is to pre-render this to canvas.
    -- it is worth noting the round corners are draw outside
    -- the button's bounds.

    -- save graphics state
    love.graphics.push()

    love.graphics.setFont(game.fonts.small)

    -- position the button
    love.graphics.translate(btn.left, btn.top)

    -- pushed down effect
    if btn.down then
        love.graphics.translate(0, 1)
    end

    -- reset draw color
    love.graphics.setColor(255, 255, 255)

    -- draw left corner (left of bounds)
    if btn.down then
        love.graphics.draw(image, quad.down.left, -15, 0)
    elseif btn.focused then
        love.graphics.draw(image, quad.focused.left, -15, 0)
    else
        love.graphics.draw(image, quad.left, -15, 0)
    end

    -- draw fill
    if btn.down then
        love.graphics.draw(btn.downfill, 0, 0)
    elseif btn.focused then
        love.graphics.draw(btn.focusfill, 0, 0)
    else
        love.graphics.draw(btn.fill, 0, 0)
    end

    -- draw right corner (right of bounds)
    if btn.down then
        love.graphics.draw(image, quad.down.right, btn.width, 0)
    elseif btn.focused then
        love.graphics.draw(image, quad.focused.right, btn.width, 0)
    else
        love.graphics.draw(image, quad.right, btn.width, 0)
    end

    -- print text
    love.graphics.print(btn.text, 0, btn.textY)

    -- restore graphics state
    love.graphics.pop()

end

function module.drawSwitch(btn)

    -- this is a very unoptimized but functional demonstration.
    -- a better way is to pre-render this to canvas.
    -- it is worth noting the round corners are draw outside
    -- the button's bounds.

    -- save graphics state
    love.graphics.push()

    -- position the button
    love.graphics.translate(btn.left, btn.top)

    -- push up/down on focus/click
    if btn.down then
        love.graphics.translate(0, 1)
    end

    -- reset draw color
    love.graphics.setColor(255, 255, 255)

    -- draw left corner (left of bounds)
    if btn.down then
        love.graphics.draw(image, quad.switch.left, -15, 0)
    elseif btn.focused then
        love.graphics.draw(image, quad.switch.focused.left, -15, 0)
    else
        love.graphics.draw(image, quad.switch.left, -15, 0)
    end

    -- draw fill
    if btn.down then
        love.graphics.draw(btn.fill, 0, 0)
    elseif btn.focused then
        love.graphics.draw(btn.focusfill, 0, 0)
    else
        love.graphics.draw(btn.fill, 0, 0)
    end

    -- draw right corner (right of bounds)
    if btn.down then
        love.graphics.draw(image, quad.switch.right, btn.width, 0)
    elseif btn.focused then
        love.graphics.draw(image, quad.switch.focused.right, btn.width, 0)
    else
        love.graphics.draw(image, quad.switch.right, btn.width, 0)
    end

    -- draw the switch button, lerped by "a" and "b" via "dt"
    local lerpX = lerp(btn.a, btn.b, btn.dt)
    local switchX = lerpX * (btn.width) - 15
    if btn.focused then
        love.graphics.draw(image, quad.switch.focused.button, switchX, 0)
    else
        love.graphics.draw(image, quad.switch.button, switchX, 0)
    end

    -- print the switch text.
    -- clamp printing to the switch bounds
    local function myStencilFunction()
       love.graphics.rectangle("fill", 0, 0, btn.width, btn.height)
    end
    love.graphics.stencil(myStencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)

    -- print option 1 text
    love.graphics.print(btn.options[1],
        (btn.width * lerpX), btn.textY)

    -- print option 2 text
    love.graphics.print(btn.options[2],
        - (btn.width * (1 - lerpX)), btn.textY)

    -- remove print limit
    love.graphics.setStencilTest()

    -- restore graphics state
    love.graphics.pop()

end

--- Apply custom button settings.
function module:setButton(btn)

    -- reset draw color
    love.graphics.setColor(255, 255, 255)

    -- store the measured text height
    local textheight = btn.height

    -- increase height for fatter buttons
    btn.height = 32

    -- center text
    btn.textY = math.floor((btn.height / 2) - (textheight / 2))

    -- overwrite drawing
    btn.draw = module.drawButton

    -- pre-render the fill to canvas
    btn.fill = love.graphics.newCanvas(btn.width, imh)
    love.graphics.setCanvas(btn.fill)
    for n=0, btn.width do
        love.graphics.draw(image, quad.fill, n, 0)
    end
    love.graphics.setCanvas()

    -- pre-render the focus fill to canvas
    btn.focusfill = love.graphics.newCanvas(btn.width, imh)
    love.graphics.setCanvas(btn.focusfill)
    for n=0, btn.width do
        love.graphics.draw(image, quad.focused.fill, n, 0)
    end
    love.graphics.setCanvas()

    -- pre-render the down fill to canvas
    btn.downfill = love.graphics.newCanvas(btn.width, imh)
    love.graphics.setCanvas(btn.downfill)
    for n=0, btn.width do
        love.graphics.draw(image, quad.down.fill, n, 0)
    end
    love.graphics.setCanvas()

end

--- Convert a button to a switch.
function module:setSwitch(btn, options)

    -- reset draw color
    love.graphics.setColor(255, 255, 255)

    -- store the measured text height
    local textheight = btn.height

    -- increase height for fatter buttons
    btn.height = 32

    -- center text
    btn.textY = math.floor((btn.height / 2) - (textheight / 2))

    -- measure options and resize the button
    for _, option in ipairs(options) do

        local ow, oh = love.graphics.newText(love.graphics.getFont(), option):getDimensions()

        -- use the larger of the options
        if ow > btn.width then
            btn.width = ow --+ math.ceil(ow * .2)
        end

    end

    -- custom switch code:
    -- "a" and "b" track the drawn position of the switch as n 0..1
    btn.value = 1
    btn.options = options
    btn.a = 0
    btn.b = 0
    btn.dt = 1

    -- swap out the callback
    if btn.callback then
        btn.callbackBase = btn.callback
    end

    -- overwrite callback to flip the switch
    btn.callback = function(btn)
            -- flip the switch value and "a"/"b" position values
            if btn.value == 1 then
                btn.value = 2
                btn.a = 0
                btn.b = 1
                btn.dt = 0
            else
                btn.value = 1
                btn.a = 1
                btn.b = 0
                btn.dt = 0
            end

            -- fire button callback
            if btn.callbackBase then
                btn.callbackBase(btn)
            end
        end

    -- overwrite drawing
    btn.draw = module.drawSwitch

    -- custom button update increases internal dt value
    btn.update = function(btn, dt)
        btn.dt = btn.dt + dt * 4
        end

    -- pre-render the fill to canvas
    btn.fill = love.graphics.newCanvas(btn.width, imh)
    love.graphics.setCanvas(btn.fill)
    for n=0, btn.width do
        love.graphics.draw(image, quad.switch.fill, n, 0)
    end
    love.graphics.setCanvas()

    -- pre-render the focus fill to canvas
    btn.focusfill = love.graphics.newCanvas(btn.width, imh)
    love.graphics.setCanvas(btn.focusfill)
    for n=0, btn.width do
        love.graphics.draw(image, quad.switch.focused.fill, n, 0)
    end
    love.graphics.setCanvas()

end

function module:createTournamentButtons()

    game.lib.widgetCollection:clear()

    game.view.ui:setButton(
        game.lib.widgetCollection:button("forecast", {
            left = 678,
            top = 46,
            text = "Forecast",
            callback = function(btn)
                end
        })
    )

    game.view.ui:setSwitch(
        game.lib.widgetCollection:button("motor", {
            left = 640,
            top = 92,
            text = "#",
            callback = function(btn)
                game.logic.player:toggleTrollingMotor()
                end
        }), {"Outboard", "Trolling"})

    game.view.ui:setButton(
        game.lib.widgetCollection:button("lures", {
            left = 625,
            top = 140,
            text = "Lures",
            callback = function(btn)
                game.states:push("tackle lures")
                end
        })
    )

    game.view.ui:setButton(
        game.lib.widgetCollection:button("rods", {
            left = 722,
            top = 140,
            text = "Rods",
            callback = function(btn)
                game.states:push("tackle rods")
                end
        })
    )

end

return module
