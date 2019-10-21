local facing = {}

local dir = Class{
  init = function(self, id, pos, angle)
    self.id = id
    self.x, self.y = pos[1], pos[2]
    self.angle = angle
    self.rad = math.rad(angle)
  end,

  spin = function(self, num)
    return facing.wrap(self.id + num)
  end,

  reverse = function(self)
    return self:spin(#facing / 2)
  end
}

facing.RIGHT      = dir(1, { 1,  0}, 0)
facing.DOWN_RIGHT = dir(2, { 1,  1}, 45)
facing.DOWN       = dir(3, { 0,  1}, 90)
facing.DOWN_LEFT  = dir(4, {-1,  1}, 135)
facing.LEFT       = dir(5, {-1,  0}, 180)
facing.UP_LEFT    = dir(6, {-1, -1}, 225)
facing.UP         = dir(7, { 0, -1}, 270)
facing.UP_RIGHT   = dir(8, { 1, -1}, 315)

facing[1] = facing.RIGHT
facing[2] = facing.DOWN_RIGHT
facing[3] = facing.DOWN
facing[4] = facing.DOWN_LEFT
facing[5] = facing.LEFT
facing[6] = facing.UP_LEFT
facing[7] = facing.UP
facing[8] = facing.UP_RIGHT

function facing.wrap(id)
  return facing[((id - 1) % #facing) + 1]
end

return facing