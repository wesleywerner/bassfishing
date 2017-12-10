--[[
   bass fishing
   tackle.lua

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

    -- lighter lines cast further.

    rods = {
        ["Pistol grip, 10 lb"] = {
            range = 5,
        },

        ["Two hand cast, 12 lb"] = {
            range = 5,
        },

        ["Pitching stick, 14 lb"] = {
            range = 4,
        },

        ["Flipping stick, 20 lb"] = {
            range = 3,
        },

        ["Spin rod, 6 lb"] = {
            range = 6,
        },

        ["Spin rod, 8 lb"] = {
            range = 5,
        },
    },

    -- lures are categorized

    lures = {
        {
            ["Crankbaits"] = {
                "Shad rapala",
                "Straight rapala",
                "Fat rapala",
                "Jointed rapala",
                "Shadling",
            },

            ["Spinnerbaits"] = {
                "Single blade",
                "Double blade",
                "Beetle",
                "Lil fishie",
            },

            ["Surface baits"] = {
                "Jitterbug",
                "Hula popper",
                "Torpedo",
                "Sputter buzz",
                "Weed walker",
                "Froggie",
                "Meadow mouse",
            },

            ["Worms"] = {
                "Culprit worm",
                "Augertail worm",
                "Paddle tail",
                "Gator tail",
                "Lizard",
                "Grub",
                "Crawfish",
            },
        }
    },

    colors = {
        ["black"] = { 0, 0, 0 },
        ["blue"] = { 0, 72, 186 },
        ["brown"] = { 150, 75, 0 },
        ["green"] = { 141, 182, 0 },
        ["gold"] = { 255, 215, 0 },
        ["yellow"] = { 223, 255, 0 },
        ["red"] = { 255, 0, 56 },
        ["pink"] = { 255, 0, 127 },
        ["purple"] = { 148, 87, 235 },
    }
}


return module
