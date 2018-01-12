--[[
   sound.lua
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

local sound = { }

local soundlist = {
    ["focus"] = { file="sound/ui-focus.ogg" },
    ["select"] = { file="sound/ui-select.ogg" },
    ["prompt"] = { file="sound/ui-prompt.ogg" },
    ["crash"] = { file="sound/crash.ogg" },
    ["outboard"] = { file="sound/outboard.ogg" },
    ["key"] = { file="sound/ui-key.ogg" },
    ["fish on"] = { file="sound/fishon PowerUp18.ogg" }
}

function sound:play(key, looping)

    -- exit here if sounds are turned off
    if not game.settings.sounds then return end

    local sfx = soundlist[key]

    if not sfx then
        print(string.format("Warning: no sound with key %q", key))
        return
    end

    -- load and cache the sound
    if not sfx.cache then

        local exists = love.filesystem.exists(sfx.file)

        if not exists then
            print(string.format("Warning: sound file %q does not exist", sfx.file))
            return
        end

        sfx.cache = love.audio.newSource(sfx.file, "static")

    end

    if not sfx.cache:isPlaying() then

        if looping then
            sfx.cache:setLooping(true)
        end

        sfx.cache:play()

    end

end

function sound:stop(key)

    -- exit here if sounds are turned off
    if not game.settings.sounds then return end

    local sfx = soundlist[key]

    if not sfx then
        print(string.format("Warning: no sound with key %q", key))
        return
    end

    if sfx.cache and sfx.cache:isPlaying() then
        sfx.cache:stop()
    end

end

function sound:pitch(key, pitch)

    -- exit here if sounds are turned off
    if not game.settings.sounds then return end

    local sfx = soundlist[key]

    if not sfx then
        print(string.format("Warning: no sound with key %q", key))
        return
    end

    if sfx.cache and sfx.cache:isPlaying() then
        pitch = math.max(0.1, pitch)
        sfx.cache:setPitch(pitch)
    end

end

return sound
