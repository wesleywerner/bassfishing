--[[
   competitors.lua

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

local module = {}

function module:update(dt)

    for _, craft in ipairs(game.lake.boats) do
        if craft.AI then
            game.logic.boat:update(craft, dt)
        end
    end

end

--- Move all the boats
function module:move()

    for _, craft in ipairs(game.lake.boats) do

        if craft.AI then

            -- move forward
            game.logic.boat:forward(craft)

            -- the boat has collided with something
            if craft.stuck then
                -- undo that move
                game.logic.boat:undoMove(craft)
                -- chance of staying put
                if math.random() < 0.05 then
                    -- turn the boat around
                    game.logic.boat:turn(craft, math.random(-2, 2) * 45)
                end
            else
                -- chance of changing course
                if math.random() < 0.1 then
                    -- turn the boat around
                    local adjustCourse = math.random(-1, 1) * 45
                    game.logic.boat:turn(craft, adjustCourse)
                end
            end

        end
    end

end

--- Get competitor names
function module:getNames()

    -- name templates
    local firstnames = {

        -- male names
        "Lance",
        "Toney",
        "Miquel",
        "Wallace",
        "Joe",
        "Haywood",
        "Hans",
        "Jerald",
        "Porter",
        "Hiram",

        -- female names
        "Shakita",
        "Karon",
        "Earnestine",
        "Sherika",
        "Kary",
        "Jeanett",
        "Diamond",
        "Classie",
        "Iesha",
        "Laura",
    }

    local surnames = {
        "Horn",
        "Mooney",
        "Mathis",
        "Nelson",
        "Wynn",
        "Hensley",
        "Levine",
        "Boone",
        "Estrada",
        "Mcmillan",
    }

    local boatnames = {
        "Esther's Dock",
        "The Agreement Healer",
        "The Animal's Thrower",
        "The Assault Courtesan",
        "The Champion's Purgatory",
        "The Cunning",
        "The Faith Bear",
        "The Groom's Bear",
        "The Humility Annihilator",
        "The Lamprey's Vigilance",
        "The Leader's Fairness",
        "The Melancholy Queen",
        "The Northwestern Serf",
        "The Paladin Ray",
        "The Profane Politician",
        "The Queen Larry",
        "The Scarab's Shield",
        "The Southeastern Herman",
        "The Warrior",
        "The Wealth Hunter",
    }

    -- assume each boat has two anglers
    local amt = #game.lake.boats * 2
    local list = { }

    for n=1, amt do

        local first = firstnames[math.random(1, #firstnames)]
        local last = surnames[math.random(1, #surnames)]
        local boat = table.remove(boatnames, math.random(1, #boatnames))
        local generatedName = string.format("%s %s", first, last)
        table.insert(list, {
            person = generatedName,
            boat = boat
        })

    end

    return list

end

return module
