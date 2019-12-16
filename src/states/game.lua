local game = {}

game.MOVE_REPEAT = 0.15
game.MOVE_BUFFER = 0.03

game.last_moves = {}
game.input_timers = {}
game.wait_timer = nil

function game:enter()
  self:start()
end

function game:start()
  self.world = World(Map("bordrtest"))

  self.world.rules:parse()
  self.world.updates:applyVisuals()
end

function game:update(dt)
  for i = 1, 3 do
    local x, y = Input.get("move (p"..i..")"):xy()
    local last_x, last_y = unpack(self.last_moves[i] or {0, 0})

    if (math.abs(x) > math.abs(last_x) or math.abs(y) > math.abs(last_y)) and (x ~= 0 or y ~= 0) then
      if not self.input_timers[i] or self.input_timers[i] > self.MOVE_BUFFER then
        self.input_timers[i] = self.MOVE_BUFFER
      elseif self.input_timers[i] <= self.MOVE_BUFFER then
        self.input_timers[i] = 0
      end
    end

    if self.input_timers[i] then
      self.input_timers[i] = self.input_timers[i] - dt
      if self.input_timers[i] <= 0 then
        if x ~= 0 or y ~= 0 then
          self:doTurn(x, y, i)
          self.input_timers[i] = self.input_timers[i] + self.MOVE_REPEAT
        else
          self.input_timers[i] = nil
        end
      end
    end

    self.last_moves[i] = {x, y}
  end

  if Input.get("wait"):pressed() then
    self.wait_timer = 0
  elseif Input.get("wait"):up() then
    self.wait_timer = nil
  end

  if self.wait_timer then
    self.wait_timer = self.wait_timer - dt
    if self.wait_timer <= 0 then
      self:doTurn(0, 0, 1)
      self.wait_timer = self.MOVE_REPEAT
    end
  end

  if Input.get("reset"):pressed() then
    self:start()
  end
end

function game:draw()
  self.world:draw()
end

function game:doTurn(x, y, player)
  utils.performance.start()

  self.world.movement:move(x, y, player)
  self.world.rules:parse()
  self.world.updates:convertUnits()
  self.world.rules:parse()
  self.world.updates:applyVisuals()
  self.world:resetOOB()

  utils.performance.stop()
end

return game