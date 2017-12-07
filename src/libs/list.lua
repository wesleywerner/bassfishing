local module = { }

local list_mt = {
    contents = { }
}

function list_mt:add(item)

    table.insert(self.contents, { item=item, selected=false })

    -- auto select first
    if #self.contents == 1 then
        self.contents[1].selected = true
    end

end

function list_mt.drawItem(id, item, selected)

end

function list_mt:draw(dt)

    for id, v in ipairs(self.contents) do
        self.drawItem(id, v.item, v.selected)
    end

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
