--[[
   messages.lua

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

module["building collision"] = "You have run aground! The accident costs you %d minutes. A home owner sitting on their porch eyes you suspiciously."

module["land collision"] = "You have run aground! The accident costs you %d minutes."

module["boat collision"] = "You have run into another boat! You lose %d minutes while you pay the owner $50 for the damage."

module["rock collision"] = "You have hit some rocks! You are relieved there is no damage but lost %d minutes checking your hull."

module["severe rock collision"] = "You have hit some rocks! You waste %d minutes of fishing time doing a hasty repair job. It will cost $100 to fix it right later."

module["jetty collision"] = "You have hit a boat dock! The owner is irate. It costs you $75 and you lose %d minutes arguing over the damages."

module["log collision"] = "You have struck a log! You lose %d minutes extracting your boat."

module["sign collision"] = "You have run into a floating sign that reads NO WAKE. Aside from a scratch or two you lose %d minutes."

-- on some rocks: You waste 30 minutes of fishing time doing a hasty repair job. It will cost $100 to fix it right later.

return module