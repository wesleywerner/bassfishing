--[[
   bass fishing
   records.lua

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

-- total number of lunkers to record
module.lunkerTop = 10

-- table where data is housed
module.data = nil

function module:load()

    self.data = game.logic.pickle:read("toplunkers")

    -- upgrade data as needed
    if not self.data.version then
        self.data.version = game.version
    end

    if not self.data.lunkers then

        game.dprint("\ngenerating a new list of top lunkers:")
        self.data.lunkers = { }

        -- generate random names
        local someNames = game.logic.competitors:getNames()

        -- add top lunkers
        for n = 1, self.lunkerTop do
            self:recordLunker(someNames[n].name, "Wes's Pond", 4 - (n * .1))
        end

    end

    self:printLunkerList()

end

function module:save()

    if not self.data then
        error("Can't save when record data is nil")
    end

    game.logic.pickle:write("toplunkers", self.data)

end

function module:printLunkerList()

    -- print the generated list
    game.dprint("\ntop lunkers:")
    if game.debug then
        for i, v in ipairs(self.data.lunkers) do
            game.dprint(string.format("%.2d) %.2f %s (%s)", i, v.weight, v.name, v.lake))
        end
    end

end

function module:recordLunker(playername, lakename, fishweight)

    -- sanity check
    if not self.data then
        error("records not initialized. try calling :readRecords() first.")
    end

    -- if the top lunkers list has the maximum number of entries
    if #self.data.lunkers >= self.lunkerTop then
        -- test if the fish is lighter than the smallest fish on record
        -- (the lunker list is sorted by weight, biggest first)
        local smallest = self.data.lunkers[#self.data.lunkers]
        if fishweight <= smallest.weight then
            -- did not make the record
            return false
        end
    end

    game.dprint(string.format("fish of %.2f kg made it to the top lunker list", fishweight))

    -- new record entry
    local newRecord = {
        name = playername,
        lake = lakename,
        weight = fishweight,
        date = os.time()
    }

    -- add the record
    table.insert(self.data.lunkers, newRecord)

    -- sort the lunker list (biggest first)
    table.sort(self.data.lunkers, function(a, b) return a.weight > b.weight end)

    -- trim the list
    while #self.data.lunkers > self.lunkerTop do
        local discarded = table.remove(self.data.lunkers)
        game.dprint(string.format("Removing %s (%.2f) from the top lunker list", discarded.name, discarded.weight))
    end

    return newRecord

end

return module
