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

--[[

    Provides a screen transition helper.

    Call new(duration, easing) to set up a transition:

        self.transition = game.view.screentransition:new(3, "outBounce")

    Then update it:

        self.transition:update(dt)

    The "scale" value indicates the transition progress from 0..1:

        love.graphics.translate(0, self.height - (self.height * self.transition.scale))

    And the "isOpen" value is true once the opening transition reaches a value of 1:

        if self.transition.isOpen then
            ...
        end

    Call close(duration, easing) to reverse the transition:

        self.transition:close(1, "inBack")

    Note: close only triggers when the open transition is complete.

    The "isClosed" value is true once the closing transition reaches a value of 1:

        if self.transition.isClosed then
            game.states:pop()
        end

]]--

local module = { }

local transition_mt = { }

function transition_mt:close(duration, easing)

    if self.isOpen then

        self.closing = true

        -- reverse the animation
        self.tween = game.lib.tween.new(duration or 1, self, { scale = 0 }, easing or "inBack")

    end

end

function transition_mt:update(dt)

    self.complete = self.tween:update(dt)

    self.isOpen = self.complete and not self.closing
    self.isClosed = self.complete and self.closing

end

function module:new(duration, easing)

    local instance = { }
    setmetatable(instance, { __index = transition_mt })

    instance.scale = 0

    instance.tween = game.lib.tween.new(duration or 3, instance,
        { scale = 1 }, easing or "outBounce")

    -- indicates the closing animation
    instance.closing = false

    return instance

end

return module
