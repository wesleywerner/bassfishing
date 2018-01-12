--[[
   bass fishing
   options.lua

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

--- Provides game options.
-- @module options

local module = { }

-- table where data is housed
module.data = nil

function module:load()

    local default = {
            version = "1",
            metric = true,
            music = true,
            sounds = true,
            clickmovement = false
        }

    self.data = game.logic.pickle:read("options", default)

    -- alias settings
    game.settings = self.data

    -- upgrade data as needed
    --if not self.data.version == "1" then
        --self.data.version = game.version
    --end

end

function module:save()

    if not self.data then
        error("Can't write empty options")
    end

    game.logic.pickle:write("options", self.data)

end

return module
