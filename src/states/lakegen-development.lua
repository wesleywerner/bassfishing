--[[
   debugmapview.lua

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

-- set private values
module.helptext = [[Bass fishing lake view.
"up"/"down": adjust cellular automata iterations
"left"/"right": change the seed
"ins"/"del": increase/decrease the noise density
"space": toggle render mode
WSAD keys moves around in render mode]]

module.legend = {
  ["Land"] = {92, 64, 32},
  ["Water"] = {16, 16, 64},
  ["Aquatic Plant"] = {0, 192, 0, 64},
  ["Tree"] = {32, 92, 32},
  ["Building"] = {192, 192, 64},
  ["Jetty"] = {128, 128, 128},
  ["Obstacle"] = {128, 64, 64},
  ["Player"] = {255, 255, 255},
  ["Structure"] = {128, 0, 128, 64},
  ["Fish"] = {128, 128, 0, 64}
}

function module:init()

    -- create a new map
    if not game.lake then
        game.lake = game.logic.genie:generate(game.defaultMapWidth,
        game.defaultMapHeight, game.defaultMapSeed,
        game.defaultMapDensity, game.defaultMapIterations)

        self:reset()
    end

    love.graphics.setFont( love.graphics.newFont( 8 ) )

end

function module:reset()

    -- prepare the player boat
    game.logic.boat:prepare(game.logic.player)
    game.logic.boat:launchBoat(game.logic.player)

end


function module:keypressed(key)
    if key == "escape" or key == "f10" then
        game.states:pop()
    elseif key == "left" then
        game.lake = game.logic.genie:generate( game.lake.width, game.lake.height,
        math.max(0, game.lake.seed - 1), game.lake.density,
        game.lake.iterations)
        self:reset()
    elseif key == "right" then
        game.lake = game.logic.genie:generate( game.lake.width, game.lake.height,
        math.max(0, game.lake.seed + 1), game.lake.density,
        game.lake.iterations)
        self:reset()
    elseif key == "up" then
        game.lake = game.logic.genie:generate( game.lake.width, game.lake.height,
        game.lake.seed, game.lake.density, math.max(0,
        game.lake.iterations + 1))
        self:reset()
    elseif key == "down" then
        game.lake = game.logic.genie:generate( game.lake.width, game.lake.height,
        game.lake.seed, game.lake.density, math.max(0,
        game.lake.iterations - 1))
        self:reset()
    elseif key == "insert" then
        game.lake = game.logic.genie:generate( game.lake.width, game.lake.height,
        game.lake.seed, math.max(0, game.lake.density + .025),
        game.lake.iterations)
        self:reset()
    elseif key == "delete" then
        game.lake = game.logic.genie:generate( game.lake.width, game.lake.height,
        game.lake.seed, math.max(0, game.lake.density - .025),
        game.lake.iterations)
        self:reset()
    elseif key == "kp-" then
        game.lake = game.logic.genie:generate( game.lake.width, math.max(30,
        game.lake.height - 1), game.lake.seed, game.lake.density,
        game.lake.iterations)
        self:reset()
    elseif key == "kp+" then
        game.lake = game.logic.genie:generate( game.lake.width, math.min(80,
        game.lake.height + 1), game.lake.seed, game.lake.density,
        game.lake.iterations)
        self:reset()
    end
end

function module:update(dt)

end

function module:draw()

  -- print help
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(self.helptext, 10, 10, 600)
  love.graphics.print(string.format("seed: %d\ndensity: %f\niter: %s", game.lake.seed, game.lake.density, game.lake.iterations), 650, 10)

  -- draw legend
  local legendx = 500
  local legendy = 10
  for key, color in pairs(self.legend) do
    love.graphics.setColor({200, 200, 200})
    love.graphics.print(key, legendx+20, legendy)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", legendx, legendy, 10, 10)
    legendy = legendy + 20
  end

  -- scale the map to fit
  love.graphics.translate(0, 200)
  love.graphics.scale(8, 8)

  for x=1, game.lake.width do
    for y=1, game.lake.height do

      local ground = game.lake.contour[x][y] > 0

      if ground then
        love.graphics.setColor(self.legend["Land"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      else
        -- draw lake depth
        local depth = game.lake.depth[x][y]
        love.graphics.setColor(0, 0, 64 + (128*depth) )
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local plant = game.lake.plants[x][y] > 0
      if plant then
        love.graphics.setColor(self.legend["Aquatic Plant"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local tree = game.lake.trees[x][y] > 0
      if tree then
        love.graphics.setColor(self.legend["Tree"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local house = game.lake.buildings[x][y] > 0
      if house then
        love.graphics.setColor(self.legend["Building"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

      local structure = game.lake.structure[x][y]
      if structure then
        love.graphics.setColor(self.legend["Structure"])
        love.graphics.rectangle("fill", x, y, 1, 1)
      end

    end
  end

  -- Draw jetties
  love.graphics.setColor(self.legend["Jetty"])
  for _, jetty in ipairs(game.lake.jetties) do
    love.graphics.rectangle("fill", jetty.x, jetty.y, 1, 1)
  end

  -- Draw obstacles
  love.graphics.setColor(self.legend["Obstacle"])
  for _, jetty in ipairs(game.lake.obstacles) do
    love.graphics.rectangle("fill", jetty.x, jetty.y, 1, 1)
  end

  -- Draw fish
  love.graphics.setColor(self.legend["Fish"])
  for _, fish in ipairs(game.lake.fish) do
    love.graphics.rectangle("fill", fish.x, fish.y, 1, 1)
  end

  -- player boat
  love.graphics.setColor(self.legend["Player"])
  love.graphics.rectangle("fill", game.logic.player.x, game.logic.player.y, 1, 1)

end

return module
