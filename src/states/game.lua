local game = {}

function game:enter()
  self.world = World(Map('bab'))

  self.rules = Rules()
  self.rules:parse(self.world)

  for i,rule in ipairs(self.rules) do
    print('Has rule: ' .. Rules.serialize(rule))
  end
end

function game:draw()
  self.world:draw()
end

return game