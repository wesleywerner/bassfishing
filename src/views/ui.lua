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
quad.switch = { }
quad.switch.left = love.graphics.newQuad(0, 112, 15, 32, imw, imh)
quad.switch.fill = love.graphics.newQuad(30, 112, 1, 32, imw, imh)
quad.switch.right = love.graphics.newQuad(136, 112, 15, 32, imw, imh)
quad.switch.button = love.graphics.newQuad(60, 112, 30, 32, imw, imh)

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

    -- pre-render the fill to canvas
    if not btn.fillimage then
        btn.fillimage = love.graphics.newCanvas(btn.width, imh)
        love.graphics.setCanvas(btn.fillimage)
        for n=0, btn.width do
            love.graphics.draw(image, quad.fill, n, 0)
        end
        love.graphics.setCanvas()
    end

    -- save graphics state
    love.graphics.push()

    love.graphics.setFont(game.fonts.small)

    -- position the button
    love.graphics.translate(btn.left, btn.top)

    -- push up/down on focus/click
    if btn.down then
        love.graphics.translate(0, 1)
        love.graphics.setColor(255, 200, 255)
    elseif btn.focused then
        love.graphics.setColor(200, 255, 200)
    else
        love.graphics.setColor(255, 255, 255)
    end

    -- draw left corner (left of bounds)
    love.graphics.draw(image, quad.left, -15, 0)

    -- draw fill
    love.graphics.draw(btn.fillimage, 0, 0)

    -- draw right corner (right of bounds)
    love.graphics.draw(image, quad.right, btn.width, 0)

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

    -- pre-render the fill to canvas
    if not btn.fillimage then
        btn.fillimage = love.graphics.newCanvas(btn.width, imh)
        love.graphics.setCanvas(btn.fillimage)
        for n=0, btn.width do
            love.graphics.draw(image, quad.switch.fill, n, 0)
        end
        love.graphics.setCanvas()
    end

    -- save graphics state
    love.graphics.push()

    -- position the button
    love.graphics.translate(btn.left, btn.top)

    -- push up/down on focus/click
    if btn.down then
        love.graphics.translate(0, 1)
        love.graphics.setColor(255, 200, 255)
    elseif btn.focused then
        love.graphics.setColor(200, 255, 200)
    else
        love.graphics.setColor(255, 255, 255)
    end

    -- draw left corner (left of bounds)
    love.graphics.draw(image, quad.switch.left, -15, 0)

    -- draw fill
    love.graphics.draw(btn.fillimage, 0, 0)

    -- draw right corner (right of bounds)
    love.graphics.draw(image, quad.switch.right, btn.width, 0)

    -- draw the switch button, lerped by "a" and "b" via "dt"
    local lerpX = lerp(btn.a, btn.b, btn.dt)
    local switchX = lerpX * (btn.width) - 15
    love.graphics.draw(image, quad.switch.button, switchX, 0)

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

    -- store the measured text height
    local textheight = btn.height

    -- increase height for fatter buttons
    btn.height = 32

    -- center text
    btn.textY = math.floor((btn.height / 2) - (textheight / 2))

end

--- Convert a button to a switch.
function module:setSwitch(btn, options)

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

end

return module
