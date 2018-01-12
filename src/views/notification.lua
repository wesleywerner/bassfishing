--[[
   notification.lua
   bass lover


   Copyright 2018 wesley werner <wesley.werner@gmail.com>

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

--- Provides in-game popup notifications.

local notify = { }

-- stores the list of notifications
local stack = { }

-- top/bottom padding
local verticalPadding = 20

-- padding between notifications
local betweenPadding = 10

-- left padding
local leftPadding = 20

-- notification size
local boxwidth = 240

-- vertical start position
local startPosition = -100

-- notification move animation time and type
local movementTime = 1
local entryTween = "outQuad"
local exitTween = "inQuad"

-- time notifications stay visible
local defaultTimeout = 6

--- Sets movement tweens on all notifications
local function recalculateTweens()

    local yposition = verticalPadding
    for n, noti in ipairs(stack) do

        if noti.hiding then

            -- hide the notification
            if not noti.tween then
                noti.tween = game.lib.tween.new(
                    movementTime * 0.5, noti,
                    {x=-noti.width-10}, exitTween)
            end

        else

            -- set the notification movement tween
            noti.tween = game.lib.tween.new(
                movementTime, noti,
                {y=yposition}, entryTween)

            -- count number of items in queue (not busy hiding)
            yposition = yposition + noti.height + betweenPadding

        end

    end

end

function notify:add(text, urgent)

    -- calculate the text height
    local textitem = love.graphics.newText(game.fonts.small)
    textitem:addf(text, boxwidth, "center")

    local notification = {
        text = textitem,
        urgent = urgent,
        x = leftPadding,
        y = startPosition,
        width = boxwidth,
        height = textitem:getHeight(),
        timeout = defaultTimeout * (urgent and 5 or 1)
    }

    table.insert(stack, notification)

    recalculateTweens()

end

function notify:clear()

    for n, noti in ipairs(stack) do
        noti.hiding = true
        noti.tween = nil
        noti.complete = false
    end

    recalculateTweens()

end

function notify:update(dt)

    for n, noti in ipairs(stack) do

        -- update tweens
        noti.complete = noti.tween:update(dt)

        -- reduce notification timeout
        if noti.timeout > 0 then

            noti.timeout = noti.timeout - dt

            -- hide this notification
            if noti.timeout < 0 then
                noti.hiding = true
                noti.tween = nil
                noti.complete = false
                recalculateTweens()
            end

        end

        -- remove hidden
        if noti.hiding and noti.complete then
            table.remove(stack, n)
            recalculateTweens()
        end

    end

end

function notify:draw()

    -- save state
    love.graphics.push()

    for n, noti in ipairs(stack) do
        if noti.urgent then
            love.graphics.setColor(game.color.notifyurgentbackground)
        else
            love.graphics.setColor(game.color.notifybackground)
        end
        love.graphics.rectangle("fill", noti.x, noti.y, boxwidth, noti.height)
        love.graphics.setColor(game.color.notifytext)
        love.graphics.rectangle("line", noti.x, noti.y, boxwidth, noti.height)
        love.graphics.draw(noti.text, noti.x, noti.y)
    end

    -- restore state
    love.graphics.pop()

end

return notify
