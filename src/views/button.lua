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

    love.graphics.pop()

end

function module_mt:update(dt)

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

end

function module:new(left, top, text, data)

    local edgeWidth = 15
    local buttonHeight = 32

    local instance = { }
    setmetatable(instance, { __index = module_mt })

    local image = love.graphics.newImage("res/button.png")
    local w, h = image:getDimensions()
    local tw, th = love.graphics.newText(love.graphics.getFont(), text):getDimensions()

    -- text padding
    local padding = math.ceil(edgeWidth / 2)

    instance.left = left
    instance.top = top
    instance.width = edgeWidth + edgeWidth + tw - padding
    instance.height = buttonHeight

    for k, v in pairs(data) do
        instance[k] = v
    end

    local renderButton = function(leftQuad, fillQuad, rightQuad)

        local canvas = love.graphics.newCanvas(instance.width)
        love.graphics.setCanvas(canvas)

        -- left
        love.graphics.draw(image, leftQuad, 0, 0)

        -- fill
        for n=0, tw - 1 - padding do
            love.graphics.draw(image, fillQuad, edgeWidth + n, 0)
        end

        -- right
        love.graphics.draw(image, rightQuad, edgeWidth + tw - padding)

        -- text
        love.graphics.printf(text, math.ceil(padding*1.5), math.ceil((h-th)/2), tw, "center")

        love.graphics.setCanvas()
        return canvas

    end

    love.graphics.setColor(255, 255, 255)

    local normLeftQuad = love.graphics.newQuad(0, 0, edgeWidth, buttonHeight, w, h)
    local normFillQuad = love.graphics.newQuad(16, 0, 1, buttonHeight, w, h)
    local normRightQuad = love.graphics.newQuad(18, 0, edgeWidth, buttonHeight, w, h)
    instance.image = renderButton(normLeftQuad, normFillQuad, normRightQuad)

    local downLeftQuad = love.graphics.newQuad(35, 0, edgeWidth, buttonHeight, w, h)
    local downFillQuad = love.graphics.newQuad(51, 0, 1, buttonHeight, w, h)
    local downRightQuad = love.graphics.newQuad(53, 0, edgeWidth, buttonHeight, w, h)
    instance.downimage = renderButton(downLeftQuad, downFillQuad, downRightQuad)

    return instance

end

return module
