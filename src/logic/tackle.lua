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
        {
            name = "Pistol grip, 10 lb",
            range = 5,
        },

        {
            name = "Two hand cast, 12 lb",
            range = 5,
        },

        {
            name = "Pitching stick, 14 lb",
            range = 4,
        },

        {
            name = "Flipping stick, 20 lb",
            range = 3,
        },

        {
            name = "Spin rod, 6 lb",
            range = 6,
        },

        {
            name = "Spin rod, 8 lb",
            range = 5,
        },
    },

    -- lures are categorized

    lures = {
        ["crankbaits"] = {
            "shad rapala",
            "straight rapala",
            "fat rapala",
            "jointed rapala",
        },

        ["spinnerbaits"] = {
            "single blade spinbait",
            "double blade spinbait",
            "beetle",
            "lil fishie",
        },

        ["surface baits"] = {
            "jitterbug",
            "popper",
            "hula popper",
            "torpedo",
            "weed walker",
            "froggie",
            "meadow mouse",
        },

        ["worms"] = {
            "culprit worm",
            "augertail worm",
            "paddle tail",
            "gator tail",
            "lizard",
            "grub",
            "crawfish",
        },
    },

    colors = {
        ["white"] = { 255, 255, 255 },
        ["black"] = { 128, 128, 128 },
        ["blue"] = { 0, 72, 255 },
        ["brown"] = { 150, 75, 0 },
        ["green"] = { 141, 255, 0 },
        ["gold"] = { 255, 215, 0 },
        ["yellow"] = { 223, 255, 0 },
        ["red"] = { 255, 0, 56 },
        ["pink"] = { 255, 0, 192 },
        ["purple"] = { 168, 107, 255 },
    }
}


return module
