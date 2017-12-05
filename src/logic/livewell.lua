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

local messages = require("views.messages")
local glob = require("logic.globals")
local tiles = require("views.tiles")

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
        table.insert( self.contents, fish )
        message = "You add the fish to your livewell."
    else
        -- sort the livewell fish by size
        table.sort( self.contents, function(a, b) return a.weight < b.weight end )
        -- see if this fish is larger than the smallest fish in your livewell
        local smallest = self.contents[1]
        if smallest.weight < fish.weight then
            release = table.remove( self.contents, 1 )
            print("smallest id", smallest.id, "releasing id", release.id)
            table.insert( self.contents, fish )
            message = "You release a smaller fish from your livewell and add this fish."
        else
            release = fish
            message = "All the fish in your livewell are larger than this fish.\nYou release it."
        end
    end

    -- sort the fish by weight
    table.sort( self.contents, function(a, b) return a.weight < b.weight end )

    -- debug
    print("\nLivewell contains:")
    for _, n in ipairs(self.contents) do
        print(string.format("%d) %.2f kg (%s)", n.id, n.weight, n.size))
    end

    -- force canvas to redraw
    self.livewellCanvas = nil

    return release, message

end

function module:render()

    -- render to canvas when necessary
    if not self.livewellCanvas then

        local w, h = 160, 150
        self.livewellCanvas = love.graphics.newCanvas( w, h )
        love.graphics.setCanvas(self.livewellCanvas)

        -- print fish details
        love.graphics.setFont(glob.fonts.medium)
        love.graphics.setColor(glob.fonts.color)
        for i, fish in ipairs(self.contents) do
            local py = (i - 1) * 24
            love.graphics.draw(tiles.image, tiles.fish[fish.size], 0, py)
            love.graphics.printf(string.format("%.2f kg", fish.weight), 0, py, w, "right")
        end

        -- release canvas
        love.graphics.setCanvas()

    end

end

function module:drawContents()

    if self.livewellCanvas then
        love.graphics.draw(self.livewellCanvas)
    end

end

return module
