--[[
   bass fishing
   records.lua

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

-- total number of lunkers to record
module.lunkerTop = 10

-- table where data is housed
module.data = nil

function module:read()

    local name = "records.txt"

    if love.filesystem.exists(name) then
        local size = nil
        local contents, size = love.filesystem.read(name, size)
        self.data = self:unpickle(contents)
    end

end

function module:write()

    local data = self:pickle(self.data)
    local size = data:len()
    local name = "records.txt"
    success, message = love.filesystem.write(name, data, size)

end

function module:applyDefaultTables()

    if not self.data.players then
        self.data.players = { }
    end

    if not self.data.lunkers then
        self.data.lunkers = { }
    end

end

function module:recordPlayer(playername)

    if not self.data.players[playername] then
        self.data.players[playername] = { }
    end

end

function module:recordLunker(playername, lakename, fishweight)

    -- if the top lunkers list has the maximum number of entries
    if #self.data.lunkers == self.lunkerTop then
        -- test if the fish is lighter than the smallest fish on record
        -- (the lunker list is sorted by weight, biggest first)
        local smallest = self.data.lunkers[#self.data.lunkers]
        if fishweight <= smallest.weight then
            -- did not make the record
            return false
        end
    end

    -- add the record
    table.insert(self.data.lunkers, {
        name = playername,
        lake = lakename,
        weight = fishweight,
        date = os.time()
    })

    -- sort the lunker list
    table.sort(self.table.lunkers, function(a, b) return a.weight > b.weight end)

end



----------------------------------------------
-- Pickle.lua
-- A table serialization utility for lua
-- Steve Dekorte, http://www.dekorte.com, Apr 2000
-- Freeware
----------------------------------------------

function module:pickle(t)
  return Pickle:clone():pickle_(t)
end

Pickle = {
  clone = function (t) local nt={}; for i, v in pairs(t) do nt[i]=v end return nt end
}

function Pickle:pickle_(root)
  if type(root) ~= "table" then
    error("can only pickle tables, not ".. type(root).."s")
  end
  self._tableToRef = {}
  self._refToTable = {}
  local savecount = 0
  self:ref_(root)
  local s = ""

  while table.getn(self._refToTable) > savecount do
    savecount = savecount + 1
    local t = self._refToTable[savecount]
    s = s.."{\n"
    for i, v in pairs(t) do
        s = string.format("%s[%s]=%s,\n", s, self:value_(i), self:value_(v))
    end
    s = s.."},\n"
  end

  return string.format("{%s}", s)
end

function Pickle:value_(v)
  local vtype = type(v)
  if     vtype == "string" then return string.format("%q", v)
  elseif vtype == "number" then return v
  elseif vtype == "boolean" then return tostring(v)
  elseif vtype == "table" then return "{"..self:ref_(v).."}"
  else --error("pickle a "..type(v).." is not supported")
  end
end

function Pickle:ref_(t)
  local ref = self._tableToRef[t]
  if not ref then
    if t == self then error("can't pickle the pickle class") end
    table.insert(self._refToTable, t)
    ref = table.getn(self._refToTable)
    self._tableToRef[t] = ref
  end
  return ref
end

----------------------------------------------
-- unpickle
----------------------------------------------

function module:unpickle(s)
  if type(s) ~= "string" then
    error("can't unpickle a "..type(s)..", only strings")
  end

  local gentables = loadstring("return "..s)

  -- silently fail if the loaded string is not valid
  if not gentables then
    --error("can't unpickle the string")
    return { }
  end

  local tables = gentables()

  for tnum = 1, table.getn(tables) do
    local t = tables[tnum]
    local tcopy = {}; for i, v in pairs(t) do tcopy[i] = v end
    for i, v in pairs(tcopy) do
      local ni, nv
      if type(i) == "table" then ni = tables[i[1]] else ni = i end
      if type(v) == "table" then nv = tables[v[1]] else nv = v end
      t[i] = nil
      t[ni] = nv
    end
  end
  return tables[1]
end

--module:write()
module:read()

return module
