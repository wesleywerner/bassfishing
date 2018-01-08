local module = { }

local list_mt = {
    contents = { },
    fillColor = {0, 0, 0},
    selectedColor = {255, 255, 255},
    textColor = {0, 0, 0}
}

function list_mt:add(item)

    table.insert(self.contents, { item=item, selected=false })

    -- auto select first
    if #self.contents == 1 then
        self.contents[1].selected = true
    end

end

function list_mt:drawItem(id, item, selected)

    local py = (id - 1) * self.itemHeight
    local px = 10

    if selected then
        love.graphics.setColor(self.fillColor)
        love.graphics.rectangle("fill", 0, py, self.width, self.itemHeight)
        love.graphics.setColor(self.selectedColor)
    else
        love.graphics.setColor(self.textColor)
    end

    love.graphics.print(item, px, py)

end

function list_mt:draw(dt)

    -- apply font
    if self.font then
        love.graphics.setFont(self.font)
    end

    -- draw items
    for id, v in ipairs(self.contents) do
        self:drawItem(id, v.item, v.selected)
    end

    -- border
    love.graphics.setColor(self.fillColor)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)

end

function list_mt:selectNext()

    local nextid = nil
    for id, v in ipairs(self.contents) do
        if not nextid and v.selected then
            nextid = math.min(#self.contents, id + 1)
            v.selected = false
        end
    end

    if nextid then
        self.contents[nextid].selected = true
    end

end

function list_mt:selectPrev()

    local nextid = nil
    for id, v in ipairs(self.contents) do
        if not nextid and v.selected then
            nextid = math.max(1, id - 1)
            v.selected = false
        end
    end

    if nextid then
        self.contents[nextid].selected = true
    end

end

function list_mt:selectIndex(index)

    index = math.max(1, math.min(index, #self.contents))

    for id, v in ipairs(self.contents) do
        v.selected = id == index
    end

end

--- select item at xy position relative to the list position.
function list_mt:selectPoint(x, y)

    local selected = false

    -- within list bounds
    if x > 0 and x < self.width then

        local i = math.ceil(y / self.itemHeight)

        -- within bounds
        if i > 0 and i <= #self.contents then

            self:selectIndex(i)
            selected = true

        end

    end

    return selected

end

function list_mt:selectedItem()

    for id, v in ipairs(self.contents) do
        if v.selected then
            return v.item
        end
    end

end

function module:new()

    local instance = { }
    setmetatable(instance, { __index = list_mt })
    return instance

end

return module
