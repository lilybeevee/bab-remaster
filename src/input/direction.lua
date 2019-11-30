local Direction = Class{
  init = function(self, nodes)
    self.nodes = nodes
  end
}

function Direction:xy()
  local x, y = 0, 0
  for _,node in ipairs(self.nodes) do
    x = utils.math.clamp(x + node:x(), -1, 1)
    y = utils.math.clamp(y + node:y(), -1, 1)
  end
  return x, y
end

function Direction:x()
  local x, y = self:xy()
  return x
end

function Direction:y()
  local x, y = self:xy()
  return y
end

Direction.Keys = Class{
  init = function(self, right, downright, down, downleft, left, upleft, up, upright)
    self.keys = {}
    self.keys[Facing.RIGHT] = right
    self.keys[Facing.DOWN_RIGHT] = downright
    self.keys[Facing.DOWN] = down
    self.keys[Facing.DOWN_LEFT] = downleft
    self.keys[Facing.LEFT] = left
    self.keys[Facing.UP_LEFT] = upleft
    self.keys[Facing.UP] = up
    self.keys[Facing.UP_RIGHT] = upright
  end,

  xy = function(self)
    local x, y = 0, 0
    for _,dir in ipairs(Facing) do
      if self.keys[dir] and Input.state[self.keys[dir]] then
        x = utils.math.clamp(x + dir.x, -1, 1)
        y = utils.math.clamp(y + dir.y, -1, 1)
      end
    end
    return x, y
  end,
  x = function(self)
    local x, y = self:xy()
    return x
  end,
  y = function(self)
    local x, y = self:xy()
    return y
  end
}

return Direction