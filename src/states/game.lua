local game = {}

local world

function game:enter()
  self.world = World(Map('bab'))
end

function game:draw()
  self.world:draw()
end

return game