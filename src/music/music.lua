--[[
   bass fishing
   music.lua

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

--- Provides playlist driven music.
-- @module music

local music = { }

-- available playlists and tracks.
-- a track can be repeating: it plays a set number of times,
-- or looping: it repeats forever, so tracks that loop should be
-- the last in the playlist, as no other tracks will play after it.
local playlists = {
    ["menu"] = {
        { looping=true, file="music/Racing-Menu.ogg" },
    },
    ["tournament"] = {
        { repeats=2, file="music/Underground-Stream.ogg" },
        { repeats=3, file="music/Strange-Nature.ogg" },
        { repeats=3, file="music/Random-Processes_Looping.ogg" },
        { repeats=1, file="music/Life-in-a-Drop.ogg" },
        { repeats=2, file="music/Plankton-Triumphs.ogg" },
        { repeats=2, file="music/Underwater-World.ogg" }
    },
    ["tournament end"] = {
        { looping=true, file="music/Guitar-Mayhem-3.ogg" }
    }
}

-- the current playlist number
local currentList = nil

-- the current track number
local currentTrack = 1

-- the playlist number to switch to after the current track fades out
local nextPlaylist = nil

-- the current music source
local source = nil

-- fade music volume gradually
local fading = false

-- remembers repeats count
local repeatcount = nil

--- Tests all sound sources exist
local testedSources = false
local function testSources()

    if testedSources then return end

    game.dprint("\nTesting music sources")

    for name, playlist in pairs(playlists) do
        for _, track in ipairs(playlist) do
            local exists = love.filesystem.exists(track.file)
            if not exists then
                print(string.format("Warning: %q does not exist", track.file))
            end
        end
    end

    testedSources = true

end

--- Returns if there is a source and it is playing
local function isPlaying()

    return source and source:isPlaying()

end

--- Stop music
function music:stop()

    if isPlaying() then
        source:stop()
        source = nil
    end

end

--- fade volume and stop music
function music:fadeout()

    if isPlaying() then
        fading = true
    end

end

--- start the music engine
function music:play(playlistname)

    testSources()

    if not currentList and not playlistname then
        error("must provide the playlist name")
    end

    -- validate playlist name
    if playlistname then

        local valid = false

        for k, v in pairs(playlists) do
            if k == playlistname then
                valid = true
            end
        end

        if not valid then
            error(string.format("No playlist named %q", playlistname))
        end

        -- use this playlist immediately
        if not currentList then
            currentList = playlistname
            currentTrack = 1
            repeatcount = 0
        else
            -- fade current playlist and queue this one next
            nextPlaylist = playlistname
            fading = true
        end

    end

    -- exit here if music is turned off
    if not game.settings.music then return end

    -- if nothing is playing switch to playlist immediately
    if not isPlaying() then
        --fading = false
        game.dprint(string.format("starting %q track %d", currentList, currentTrack))
        local track = playlists[currentList][currentTrack]
        source = love.audio.newSource(track.file, "stream")
        -- start off low volume
        source:setVolume(0.1)
        -- this is a looping track
        if track.looping then
            source:setLooping(true)
        end
        source:play()
        repeatcount = repeatcount + 1
    else
        game.dprint(string.format("set next playlist to %q", playlistname))
        game.dprint("muting current track")
        nextPlaylist = playlistname
        self:fadeout()
    end

end

--- Update music state.
function music:update(dt)

    -- exit here if music is turned off
    if not game.settings.music then return end

    if isPlaying() then

        -- fade volume
        if fading then

            local volume = math.max(0, source:getVolume() - dt * 0.25)
            --game.dprint(string.format("%s: fading volume to %.2f", os.date("%c", os.time()), volume))
            source:setVolume(volume)

            -- fade is complete
            if volume == 0 then

                game.dprint("track is faded out. stopping track.")

                -- done fading
                fading = false

                -- stop playing
                source:stop()

                -- move to next playlist
                if nextPlaylist then

                    game.dprint(string.format("forwarding to next playlist %q", nextPlaylist))

                    currentList = nextPlaylist
                    currentTrack = 1
                    repeatcount = 0

                    -- clear next playlist
                    nextPlaylist = nil

                    -- play the new track
                    self:play()

                end

            end

        else
            -- gradually increase volumne
            local volume = source:getVolume()

            if volume < 1 then
                volume = math.min(1, volume + dt * 0.25)
                --game.dprint(string.format("upping volume to %.2f", volume))
                source:setVolume(volume)
            end
        end

    else

        local track = playlists[currentList][currentTrack]

        -- test if we need to repeat this track again
        if repeatcount >= track.repeats then

            -- move to next track
            currentTrack = currentTrack + 1

            -- repeat playlist
            if currentTrack > #playlists[currentList] then
                currentTrack = 1
            end

            -- reset repeat for the new track
            repeatcount = 0

        end

        game.dprint(string.format("current track has stopped, moving to track %d", currentTrack))

        -- play the new track
        self:play()

    end

end

return music
