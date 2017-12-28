--[[
   bass fishing
   stats.lua

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

--- Provides statistics of the current angler.
-- @module stats

local module = { }

-- table where data is housed
module.data = nil

function module:load(name)

    self.filename = string.format("angler %s", name)
    self.data = game.logic.pickle:read(self.filename)

    -- angler file does not exist, create version 1
    if not self.data.version then
        self.data.version = game.version
        self.data.name = name
        -- add new values below in the upgrade tests
    end

    -- upgrade data as needed
    if self.data.version ~= game.version  then
        if self.data.version == "1" then
            --print("upgrade from V1")
        elseif self.data.version == "2" then
            --print("upgrade from V2")
        end
    end

    if game.debug then self:printDetails() end

end

function module:save()

    if not self.data then
        error("Can't write empty angler stats")
    end

    game.logic.pickle:write(self.filename, self.data)

    game.dprint("written angler stats")

end

function module:printDetails()

    -- print the generated list
    if game.debug then
        game.dprint(string.format("Details for angler %q:", self.data.name))
        for k, v in pairs(self.data) do
            game.dprint(string.format("%s: %s", k, v))
        end
    end

end

return module
