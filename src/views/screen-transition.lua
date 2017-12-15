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

-- list of screen effects
local effects = {
    ["center zoom"] = 1,
    ["slide up"] = 2
}

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

--- Apply a specific screen animation.
function transition_mt:apply(effect, param)

    local effno = self.effects[effect]

    if effno == 1 then

        -- center the map on screen adjusting for the screen transition
        love.graphics.translate(self.centerX - (self.centerX * self.scale),
            self.centerY - (self.centerY * self.scale))

        -- scale the state into view
        love.graphics.scale(self.scale, self.scale)

    elseif effno == 2 then

        -- param is the height to animate from
        love.graphics.translate(0, (param or self.height) - ((param or self.height) * self.scale))

    end

end

function module:new(duration, easing)

    -- create a new instance and inherit functions
    local instance = { }
    setmetatable(instance, { __index = transition_mt })

    -- start at zero
    instance.scale = 0

    -- animate towards 1
    instance.tween = game.lib.tween.new(duration or 3, instance,
        { scale = 1 }, easing or "outBounce")

    -- indicates the closing animation
    instance.closing = false

    -- store screen size and center position
    instance.width = love.graphics.getWidth()
    instance.height = love.graphics.getHeight()
    instance.centerX = instance.width / 2
    instance.centerY = instance.height / 2

    -- copy effects enums
    instance.effects = effects

    return instance

end

return module
