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

function module:readRecords()

    self.data = game.logic.pickle:read("records")

    -- upgrade data as needed
    if not self.data.version then
        self.data.version = 1
    end

    if not self.data.players then
        self.data.players = { }
    end

    if not self.data.lunkers then

        game.dprint("generating new list of top lunkers")
        self.data.lunkers = { }

        -- generate random names
        local someNames = game.logic.competitors:getNames()

        -- add top lunkers
        for n = 1, self.lunkerTop do
            self:recordLunker(someNames[n].name, "Wes's Pond", 3 - (n * .1))
        end

        -- print the generated list
        if game.debug then
            for i, v in ipairs(self.data.lunkers) do
                game.dprint(string.format("%.2d) %.2f %s (%s)", i, v.weight, v.name, v.lake))
            end
        end

    end


end

function module:recordPlayer(playername)

    -- sanity check
    if not self.data then
        error("records not initialized. try calling :readRecords() first.")
    end

    if not self.data.players[playername] then
        self.data.players[playername] = { }
    end

end

function module:recordLunker(playername, lakename, fishweight)

    -- sanity check
    if not self.data then
        error("records not initialized. try calling :readRecords() first.")
    end

    -- if the top lunkers list has the maximum number of entries
    if #self.data.lunkers == self.lunkerTop then
        -- test if the fish is lighter than the smallest fish on record
        -- (the lunker list is sorted by weight, biggest first)
        local smallest = self.data.lunkers[#self.data.lunkers]
        if fishweight <= smallest.weight then
            -- did not make the record
            return false
        end
    end

    -- add the record
    table.insert(self.data.lunkers, {
        name = playername,
        lake = lakename,
        weight = fishweight,
        date = os.time()
    })

    -- sort the lunker list
    table.sort(self.data.lunkers, function(a, b) return a.weight > b.weight end)

end

return module
