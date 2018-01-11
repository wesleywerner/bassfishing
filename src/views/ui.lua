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
    love.graphics.printf(btn.text, 0, btn.textY, btn.width, "center")

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
    local offset = (btn.width * lerpX)
    love.graphics.printf(btn.options[1], offset, btn.textY, btn.width, "center")

    -- print option 2 text
    local offset = - (btn.width * (1 - lerpX))
    love.graphics.printf(btn.options[2], offset, btn.textY, btn.width, "center")

    -- remove print limit
    love.graphics.setStencilTest()

    -- restore graphics state
    love.graphics.pop()

end

--- Apply custom button settings.
function module:setButton(btn, width)

    -- reset draw color
    love.graphics.setColor(255, 255, 255)

    -- store the measured text height
    local textheight = btn.height

    -- increase height for fatter buttons
    btn.height = 32

    -- overwrite width
    if width then
        btn.width = width
    end

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

    -- swap out the callback
    if btn.callback then
        btn.callbackBase = btn.callback
    end

    -- overwrite callback to flip the switch
    btn.callback = function(btn)
        game.sound:play("select")
        -- fire button callback
        if btn.callbackBase then
            btn.callbackBase(btn)
        end
    end

end

--- Convert a button to a switch.
function module:setSwitch(btn, options, width)

    -- reset draw color
    love.graphics.setColor(255, 255, 255)

    -- store the measured text height
    local textheight = btn.height

    -- increase height for fatter buttons
    btn.height = 32

    -- center text
    btn.textY = math.floor((btn.height / 2) - (textheight / 2))

    if width then
        btn.width = width
    else
        -- measure options and resize the button
        for n, option in ipairs(options) do
            local ow, oh = love.graphics.newText(love.graphics.getFont(), option):getDimensions()
            -- use the larger of the options
            if ow > btn.width then
                btn.width = ow
            end
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

    btn.setOption = function(btn, newvalue)
        btn.value = newvalue
        if btn.value == 1 then
            btn.a = 1
            btn.b = 0
            btn.dt = 0
        else
            btn.a = 0
            btn.b = 1
            btn.dt = 0
        end
    end

    -- overwrite callback to flip the switch
    btn.callback = function(btn)

            game.sound:play("focus")

            -- flip the switch value and "a"/"b" position values
            if btn.value == 1 then
                btn:setOption(2)
            else
                btn:setOption(1)
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

function module:chart(width, height)

    local function drawGrid(chart, width, height)

        love.graphics.setColor(game.color.base3)

        -- vertical lines
        for x=0, width, 20 do
            love.graphics.line(x, 0, x, height)
        end

        -- horizontal lines
        for y=0, height, 20 do
            love.graphics.line(0, y, width, y)
        end

        -- print no-data text
        if #chart.datapoints == 0 or #chart.datapoints[1].points < 2 then

            love.graphics.setColor(game.color.yellow)
            love.graphics.setFont(game.fonts.small)
            love.graphics.printf("no data yet", 0, 0, width, "center")

        end

    end

    local function drawLabels(chart, labels)

        love.graphics.setColor(game.color.base0)
        love.graphics.setFont(game.fonts.tiny)

        for _, label in ipairs(labels) do

            -- print label text
            if label.axiz == "x" then
                --love.graphics.print(
                    --label.text,
                    --math.floor(label.x), math.floor(label.y + 12))
            else
                -- draw label point
                --love.graphics.line(chart.width, label.y, chart.width + 20, label.y)

                local text = label.text

                if chart.formatWeight then
                    text = game.lib.convert:weight(label.text, false)
                else
                    text = math.ceil(text)
                end

                love.graphics.print(text, math.floor(4 + chart.width),
                math.floor(label.y))
            end

        end

    end

    local function drawBorder(chart, width, height)

        love.graphics.setColor(game.color.base1)
        love.graphics.rectangle("line", 0, 0, width, height)

    end

    local function drawLine(chart, dataset, node1, node2)

        love.graphics.setColor(game.color.blue)
        love.graphics.setLineWidth(4)
        love.graphics.line(node1.x, node1.y, node2.x, node2.y)
        love.graphics.setLineWidth(1)

    end

    local function drawNode(chart, dataset, node)

        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(game.color.blue)

        if node.focus then
            love.graphics.setColor(game.color.magenta)
            love.graphics.circle("fill", node.x, node.y, 6)
            -- tooltip
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", node.x + 20, node.y - 4, 120, 40)
            love.graphics.setColor(game.color.white)
            local nodeText = string.format("tour #%d\n%s", node.a, game.lib.convert:weight(node.b))
            love.graphics.print(nodeText, math.floor(node.x + 24), math.floor(node.y))
        else
            love.graphics.circle("fill", node.x, node.y, 6)
        end

    end

    local function drawFill(chart, dataset, triangles)

        if dataset == "dataset 1" then
            love.graphics.setColor(211, 54, 130, 64)
        else
            love.graphics.setColor(38, 139, 210, 64)
        end

        for _, triangle in ipairs(triangles) do
            love.graphics.polygon("fill", triangle)
        end

    end

    local chart = game.lib.chart(width, height)
    chart.drawGrid = drawGrid
    chart.drawLabels = drawLabels
    chart.drawBorder = drawBorder
    chart.drawLine = drawLine
    chart.drawNode = drawNode
    chart.drawFill = drawFill

    return chart

end

return module
