--[[
   ai.lua

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

    http://www.umpquavalleybassmasters.com/bassbook.htm

    * "You may find structure which at the moment is not holding bass
    but you will NEVER find bass without structure."

    *  The larger the bass become, the more likely they are to prefer
    deeper water and the harder it is for fishermen to find them.

    * To find relief from bright light the bass must head for the
    depths and remain at some level where sunlight cannot penetrate or
    retreat into the shaded comfort of "colored" water or places where
    there are expanses of very heavily matted bottom weed-beds, lily
    pads, submerged brush, or felled trees.

    * Reduced light penetration, such as during low-light periods of
    early morning or late evening or even after dark, might see the
    bass move to shallower water upon occasion. Cold front weather
    conditions might see them move considerably deeper! As a general
    rule, bass will go as deep as need be to feel safe and avoid bright
    light.

    * The place where a school of bass rests in deep water between
    feeding cycles is called the sanctuary.

    * Because the sanctuary is normally in deeper water, pinpointing
    its exact location is nearly impossible.

    * When in the sanctuary, the school of bass is in a rather inactive
    state and can seldom be tempted into biting or provoked into
    striking.

    * The school of bass will occasionally, most frequently on a
    schedule, migrate or travel from the sanctuary to some other area a
    short distance away, usually into somewhat shallower water, and
    they are now in a highly active feeding state.

    * The largemouth seems most comfortable when the water is between
    65 and 75 F. As the water chills, their metabolism starts to slow
    down and in cold water bass are very sluggish.

    * Bass become uncomfortable when the water temperatures rise above
    80. That's when the bass will be found along shaded or windy
    shorelines where wave action pumps oxygen into the water, or among
    aquatic plants which produce oxygen.

    * Bass need not to be feeding for you to catch them; instincts
    other than hunger will cause them to strike. Mere curiosity, an
    instinctive attack reaction

    * Weather has far more effect on fishermen than on fish anywhere.
    If you can find bass at all, it is possible to catch them whether
    it is raining and windy or calm with bright sunshine.

    * The importance of fishing a lure close to the bottom cannot be
    overemphasized.

    * The more quietly an angler behaves, the better his chances.
    Banging a tackle box against the bottom of a boat, having creaky or
    loose oarlocks, rowing or paddling with splashing action, and other
    noise producing activities are to be avoided because they frighten
    the bass. When frightened, the bass become uneasy and on-guard and
    either quickly leave the area or cease feeding.

    * As a bass gets bigger, it gets tougher to fool.

]]--

local module = {}
local glob = require("globals")
local lume = require("lume")
local boat = require("boat")


function module:update(dt)

    for _, craft in ipairs(glob.lake.boats) do
        if craft.AI then
            boat:update(craft, dt)
        end
    end

end

--- Move all the boats
function module:move()

    for _, craft in ipairs(glob.lake.boats) do

        if craft.AI then

            -- move forward
            boat:forward(craft)

            -- the boat has collided with something
            if craft.stuck then
                -- undo that move
                boat:undoMove(craft)
                -- chance of staying put
                if math.random() < 0.05 then
                    -- turn the boat around
                    boat:turn(craft, math.random(-2, 2) * 45)
                end
            else
                -- chance of changing course
                if math.random() < 0.1 then
                    -- turn the boat around
                    local adjustCourse = math.random(-1, 1) * 45
                    boat:turn(craft, adjustCourse)
                end
            end

        end
    end

end

return module
