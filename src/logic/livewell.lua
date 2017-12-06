--[[
   livewell.lua

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

local module = {

    -- the contents of the livewell
    contents = { },

    -- number of fish allowed in livewell at the same time
    capacity = 5,

}

--- Adds a fish to the livewell.
-- Returns the fish to release into the water, and any messages to display.
function module:add(fish)

    local message = ""
    local release = nil

    -- add the fish
    if #self.contents < self.capacity then

        -- hilite the fish in the live well list for a visual effect
        fish.hilite = 1
        table.insert( self.contents, fish )
        message = "You add the fish to your live well."

    else

        -- sort the livewell fish by size
        table.sort( self.contents, function(a, b) return a.weight < b.weight end )

        -- see if this fish is larger than the smallest fish in your livewell
        local smallest = self.contents[1].weight

        if smallest < fish.weight then

            -- release our smallest fish
            release = table.remove( self.contents, 1 )

            -- add the new fish
            fish.hilite = 1
            table.insert( self.contents, fish )

            message = "You release a smaller fish from your live well and add this fish."

        else
            release = fish
            message = "All the fish in your live well are larger than this fish.\nYou release it."
        end

    end

    -- sort the fish by weight
    table.sort( self.contents, function(a, b) return a.weight < b.weight end )

    -- debug
    print("\nLivewell contains:")
    for _, n in ipairs(self.contents) do
        print(string.format("%d) %.2f kg (%s)", n.id, n.weight, n.size))
    end

    -- return the fish to release (if any) and a message to the angler
    return release, message

end

return module
