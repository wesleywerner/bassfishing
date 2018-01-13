--[[
   bass fishing
   anglers.lua

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

--- Provides the list of anglers on record for selection on sign-in.
-- @module anglers

local module = { }

-- table where data is housed
module.data = nil

function module:load()

    local default = {
        version = game.version
    }

    self.data = game.logic.pickle:read("anglers", default)

    -- upgrade data as needed
    --if self.data.version == 2 then

    --end

    -- update to current game version
    self.data.version = game.version

    if game.debug then self:printList() end

end

function module:save()

    if not self.data then
        error("Can't write empty angler list")
    end

    game.logic.pickle:write("anglers", self.data)

    game.dprint("written anglers list")

end

function module:printList()

    -- print the generated list
    if game.debug then
        game.dprint("\nlist of anglers:")
        for i, v in ipairs(self.data) do
            game.dprint(string.format("%.2d) %s", i, v.name))
        end
    end

end

function module:addAngler(name)

    -- sanity check
    if not self.data then
        self.data = { }
    end

    -- add the record
    table.insert(self.data, { name=name })

    game.dprint(string.format("added angler %q", name))

    self:save()

end

return module
