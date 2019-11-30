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
  self.world = World(Map("bab"))

  self.world.rules:parse()
  self.world.updates:applyVisuals()
end

function game:update(dt)
  for i = 1, 3 do
    local x, y = Input.get("move (p"..i..")"):xy()
    local last_x, last_y = unpack(self.last_moves[i] or {0, 0})

    local timer = self.input_timers[i]

    if last_x ~= x or last_y ~= y then
      if not timer or timer.time > self.MOVE_BUFFER then
        if x ~= 0 or y ~= 0 then
          timer = {x = x, y = y, time = self.MOVE_BUFFER}
          self.input_timers[i] = timer
        else
          timer = nil
          self.input_timers[i] = nil
        end
      elseif timer.time <= self.MOVE_BUFFER and (x ~= 0 or y ~= 0) then
        timer.x = x
        timer.y = y
        timer.time = 0
      else
        timer = nil
        self.input_timers[i] = nil
      end
    end

    if timer then
      timer.time = timer.time - dt
      if timer.time <= 0 then
        self:doTurn(timer.x, timer.y, i)
        timer.time = self.MOVE_REPEAT
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
  self.world.updates:applyVisuals()

  utils.performance.stop()
end

return game