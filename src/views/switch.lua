local module = { }

local module_mt = { }

function module_mt:istouched(x, y)

  return x > self.left and x < self.left + self.width
    and y > self.top and y < self.top + self.height

end

function module_mt:draw()

    love.graphics.setColor(game.color.white)
    love.graphics.setFont(game.fonts.small)

    love.graphics.push()

    if self.down then
        love.graphics.translate(0, 1)
        love.graphics.draw(self.downimage, self.left, self.top)
    elseif self.hover then
        love.graphics.translate(0, -1)
        love.graphics.draw(self.image, self.left, self.top)
    else
        love.graphics.draw(self.image, self.left, self.top)
    end

    if self.selected == 1 then
        love.graphics.draw(self.switchImage, self.switchLeft, self.top)
        love.graphics.print(self.options[1], self.option1Left, self.option1Top)
        --love.graphics.draw(self.option1, self.option1Left, self.top)
    else
        love.graphics.draw(self.switchImage, self.switchLeft, self.top)
        love.graphics.print(self.options[2], self.option2Left, self.option1Top)
        --love.graphics.draw(self.option2, self.option2Left, self.top)
    end

    love.graphics.pop()

end

function module_mt:update(dt)

    if self.tween then
        if self.tween:update(dt) then
            self.tween = nil
        end
    end

end

function module_mt:mousemoved(x, y, dx, dy, istouch)

    self.hover = self:istouched(x, y)

end

function module_mt:mousepressed(x, y, button, istouch)

    self.down = self:istouched(x, y)

end

function module_mt:mousereleased(x, y, button, istouch)

    self.hover = self:istouched(x, y)
    self.down = false

    if self.hover then
        self:toggleSwitch()
    end

end

function module_mt:toggleSwitch()

    if self.selected == 1 then
        self.selected = 2
        self.tween = game.lib.tween.new(.3, self, { switchLeft=self.switch2Left})
    else
        self.selected = 1
        self.tween = game.lib.tween.new(.3, self, { switchLeft=self.switch1Left})
    end

end

function module:new(left, top, options, data)

    local edgeWidth = 15
    local buttonHeight = 32
    local switchWidth = 30

    local instance = { }
    setmetatable(instance, { __index = module_mt })

    local image = love.graphics.newImage("res/button.png")
    local w, h = image:getDimensions()

    -- measure the largest option text
    local tw, th = 0, 0
    for _, opt in ipairs(options) do
        local ow, oh = love.graphics.newText(love.graphics.getFont(), opt):getDimensions()
        if ow > tw then tw = ow end
        if oh > th then th = oh end
    end

    -- selected option
    instance.options = options
    instance.selected = 1
    instance.switchWidth = switchWidth
    instance.left = left
    instance.top = top
    instance.width = edgeWidth + switchWidth + edgeWidth + tw
    instance.height = buttonHeight

    for k, v in pairs(data) do
        instance[k] = v
    end

    local renderButton = function(leftQuad, fillQuad, rightQuad)

        local canvasWidth = instance.width
        local canvas = love.graphics.newCanvas(instance.width)
        love.graphics.setCanvas(canvas)

        -- left
        love.graphics.draw(image, leftQuad, 0, 0)

        -- fill
        for n=0, (tw + switchWidth) - 1 do
            love.graphics.draw(image, fillQuad, edgeWidth + n, 0)
        end

        -- right
        love.graphics.draw(image, rightQuad, edgeWidth + switchWidth + tw)

        love.graphics.setCanvas()
        return canvas

    end

    --local renderOption = function(text)

        --local canvas = love.graphics.newCanvas(instance.width)
        --love.graphics.setCanvas(canvas)

        ---- text
        --love.graphics.printf(text, 0, math.ceil((h-th)/2), tw, "center")

        --love.graphics.setCanvas()
        --return canvas

    --end

    local extractSwitch = function(quad)
        local canvas = love.graphics.newCanvas(switchWidth)
        love.graphics.setCanvas(canvas)
        love.graphics.draw(image, quad, 0)
        love.graphics.setCanvas()
        return canvas
    end

    love.graphics.setColor(255, 255, 255)

    local normLeftQuad = love.graphics.newQuad(75, 0, edgeWidth, buttonHeight, w, h)
    local normFillQuad = love.graphics.newQuad(91, 0, 1, buttonHeight, w, h)
    local normRightQuad = love.graphics.newQuad(93, 0, edgeWidth, buttonHeight, w, h)
    local normSwitchQuad = love.graphics.newQuad(146, 0, 30, buttonHeight, w, h)
    instance.image = renderButton(normLeftQuad, normFillQuad, normRightQuad)

    local downLeftQuad = love.graphics.newQuad(110, 0, edgeWidth, buttonHeight, w, h)
    local downFillQuad = love.graphics.newQuad(126, 0, 1, buttonHeight, w, h)
    local downRightQuad = love.graphics.newQuad(128, 0, edgeWidth, buttonHeight, w, h)
    --local downSwitchQuad = love.graphics.newQuad(181, 0, 30, buttonHeight, w, h)
    instance.downimage = renderButton(downLeftQuad, downFillQuad, downRightQuad)

    --instance.option1 = renderOption(options[1])
    --instance.option2 = renderOption(options[2])

    instance.switch1Left = instance.left
    instance.switch2Left = instance.left + instance.width - instance.switchWidth
    instance.switchLeft = instance.switch1Left

    instance.option1Left = instance.left + instance.switchWidth + (instance.switchWidth / 2)
    instance.option2Left = instance.left + (instance.switchWidth / 2)
    instance.option1Top = instance.top + math.ceil((h-th)/2)

    instance.switchImage = extractSwitch(normSwitchQuad)
    instance.switchQuad = normSwitchQuad

    return instance

end

return module
