local game = {}

function game:enter()
  self:start()
end

function game:start()
  self.world = World(Map("bab"))

  self.world.rules:parse()
  self.world:updateUnits()
end

function game:draw()
  self.world:draw()
end

function game:keypressed(key)
  if key == "d" or key == "right" or key == "kp6" then
    self:doTurn(1, 0)
  elseif key == "kp3" then
    self:doTurn(1, 1)
  elseif key == "s" or key == "down" or key == "kp2" then
    self:doTurn(0, 1)
  elseif key == "kp1" then
    self:doTurn(-1, 1)
  elseif key == "a" or key == "left" or key == "kp4" then
    self:doTurn(-1, 0)
  elseif key == "kp7" then
    self:doTurn(-1, -1)
  elseif key == "w" or key == "up" or key == "kp8" then
    self:doTurn(0, -1)
  elseif key == "kp9" then
    self:doTurn(1, -1)
  elseif key == "space" then
    self:doTurn(0, 0)
  elseif key == "r" then
    self:start()
  end
end

function game:doTurn(x, y)
  utils.performance.start()

  self.world.movement:move(x, y)
  self.world.rules:parse()
  self.world:updateUnits()

  utils.performance.stop()
end

return game