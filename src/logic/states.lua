--[[
   states.lua

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

--- Provides a simple state manager.
-- @module states

local module = {}

-- Lists all available states
module.list = {}

-- Tracks the state history
module.stack = {}

function module:add(name, object)

    if self.list[name] then
        error(string.format("There is already a state named %q in the state list", name))
    end

    self.list[name] = object

    -- default state
    if #self.stack == 0 then
        self:push(name)
    end

end

function module:get()

    if #self.stack == 0 then
        error("Cannot get anything from an empty state stack. Try pushing something on the state first.")
    end

    return self.stack[#self.stack]

end

--- Returns the name of current state
function module:current()

    return self:get().name

end

function module:push(name, data)

    if not self.list[name] then
        error(string.format("Cannot push an unknown state: %q", name))
    end

    -- ignore pushing the same state
    --if #self.stack > 0 and self.stack[#self.stack].name == name then
    --    game.dprint("not pushing the same state")
    --    return
    --end

    table.insert(self.stack, { name=name, object=self.list[name], data=data or {} })
    self:initCurrent()

end

function module:pop()

    if #self.stack > 0 then
        table.remove(self.stack)
    end

end

function module:initCurrent()

    if #self.stack == 0 then return end
    local item = self:get()
    item.object:init(item.data)

end

-- hook into love events
function module:update(dt)

    -- nothing left to do
    if #self.stack == 0 then
        love.event.quit()
    else
        self:get().object:update(dt)
    end

end

function module:keypressed(key)
    if #self.stack == 0 then return end
    local object = self:get().object
    if object.keypressed then
        self:get().object:keypressed(key)
    end
end

function module:mousemoved( x, y, dx, dy, istouch )
    if #self.stack == 0 then return end
    local object = self:get().object
    if object.mousemoved then
        self:get().object:mousemoved( x, y, dx, dy, istouch )
    end
end

function module:mousepressed( x, y, button, istouch )
    if #self.stack == 0 then return end
    local object = self:get().object
    if object.mousepressed then
        object:mousepressed( x, y, button, istouch )
    end
end

function module:mousereleased(x, y, button, istouch)
    if #self.stack == 0 then return end
    local object = self:get().object
    if object.mousereleased then
        object:mousereleased(x, y, button, istouch)
    end
end

function module:wheelmoved(x, y)
    if #self.stack == 0 then return end
    local object = self:get().object
    if object.wheelmoved then
        object:wheelmoved(x, y)
    end
end

function module:draw()
    if #self.stack == 0 then return end
    self:get().object:draw()
end

return module
