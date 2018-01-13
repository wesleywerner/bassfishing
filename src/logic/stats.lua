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

        -- stores file version
        self.data.version = game.version

        -- stores the angler name
        self.data.name = name

        -- stores a list of tournament statistics
        self.data.tours = { }

        -- WARNING: for new versions
        -- add new storage values below in the upgrade tests
    end

    -- upgrade data as needed
    if self.data.version ~= game.version  then
        if self.data.version == "1" then
            --print("upgrade from V1")
        elseif self.data.version == "2" then
            --print("upgrade from V2")
        end
    end

    self:updateStatistics()

    if game.debug then self:printDetails() end

end

function module:save()

    if not self.data then
        error("Can't write empty angler stats")
    end

    game.logic.pickle:write(self.filename, self.data)

end

function module:printDetails()

    -- print the generated list
    if game.debug then

        game.dprint(string.format("file version: %s", self.data.version))
        game.dprint(string.format("number of tours: %d", #self.data.tours))

        for k, v in pairs(self.data.total) do
            game.dprint(string.format("total %s: %.2f", k, v))
        end

    end

end

function module:record(data)

    if not self.data then
        print("Warning: Statistics data is empty. Cannot record stats.")
        return false
    end

    -- add date
    data.date = os.time()

    -- record this tour
    table.insert(self.data.tours, data)
    self:updateStatistics()
    self:save()

end

function module:updateStatistics()

    self.data.total = {
        fish=0,
        weight=0,
        heaviest=0
    }

    -- alias for totals
    local total = self.data.total

    for _, tour in ipairs(self.data.tours) do

        -- default tour values
        tour.casts = tour.casts or 0
        tour.standing = tour.standing or 0
        tour.lake = tour.lake or "NONE"
        tour.days = tour.days or 3

        -- reset totals
        tour.weight = 0

        for _, fish in ipairs(tour.fish) do

            -- total number of fish
            total.fish = total.fish + 1

            -- total fish weight
            total.weight = total.weight + fish.weight

            -- tour total weight
            tour.weight = tour.weight + fish.weight

            -- heaviest fish ever caught
            if fish.weight > total.heaviest then
                total.heaviest = fish.weight
            end

        end

    end

end

return module
