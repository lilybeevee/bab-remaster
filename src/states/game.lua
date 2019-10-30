local game = {}

game.movement = require "src.game.movement"

function game:enter()
  self.world = World(Map("ruletest"))

  self.rules = Rules(self.world)
  self.rules:parse()

  for i,rule in ipairs(self.rules) do
    print("Has rule: " .. Rules.serialize(rule))
  end
end

function game:draw()
  self.world:draw()
end

function game:keypressed(key)
  if key == "w" or key == "up" then
    self:doTurn(0, -1)
  elseif key == "s" or key == "down" then
    self:doTurn(0, 1)
  elseif key == "a" or key == "left" then
    self:doTurn(-1, 0)
  elseif key == "d" or key == "right" then
    self:doTurn(1, 0)
  end
end

function game:doTurn(x, y)
  self.movement.doMove(x, y)
  self.rules:parse(self.world)
end

return game