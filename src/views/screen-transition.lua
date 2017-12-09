--[[
   bass fishing
   screen-transition.lua

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

local transition_mt = { }

function transition_mt:close(duration, easing)

    if not self.closing and self.complete then

        self.closing = true

        -- reverse the animation
        self.tween = game.lib.tween.new(duration or 1, self, { scale = 0 }, easing or "inBack")

    end

end

function transition_mt:update(dt)

    self.complete = self.tween:update(dt)

end

function module:new(duration, easing)

    local instance = { }
    setmetatable(instance, { __index = transition_mt })

    instance.scale = 0
    instance.tween = game.lib.tween.new(duration or 3, instance, { scale = 1 }, easing or "outBounce")
    -- indicates the closing animation
    instance.closing = false

    return instance

end

return module
