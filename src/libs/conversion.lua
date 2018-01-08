--[[
   convert.lua

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

module.metric = true

function module:kglb(value)
    return value / 0.45359237
end

function module:lbkb(value)
    return value * 0.45359237
end

function module:cf(value)
    return value * 1.8 + 32
end

function module:fc(value)
    return (value - 32) / 1.8
end

function module:kphmph(value)
    return value / 1.609344
end

function module:mphkph(value)
    return value * 1.609344
end

function module:mf(value)
    return value * 3.2808398950131
end

function module:weight(value, rounded)

    if self.metric then
        if rounded then
            return string.format("%d kg", value)
        else
            return string.format("%.2f kg", value)
        end
    else
        if rounded then
            return string.format("%d lb", self:kglb(value))
        else
            return string.format("%.2f lb", self:kglb(value))
        end
    end

end

function module:temp(value)

    if self.metric then
        return string.format("%d°C", value)
    else
        return string.format("%d°F", self:cf(value))
    end

end

function module:speed(value)

    if self.metric then
        return string.format("%d kph", value)
    else
        return string.format("%d mph", self:kphmph(value))
    end

end

function module:distance(value)

    if self.metric then
        return string.format("%d m", value)
    else
        return string.format("%d ft", self:mf(value))
    end

end

return module
