local facing = {}

facing.names = {}

local dir = Class{
  init = function(self, name, id, pos, angle)
    self.id = id
    self.x, self.y = pos[1], pos[2]
    self.angle = angle
    self.rad = math.rad(angle)
    self.name = name

    facing[id] = self
    facing[self.x..","..self.y] = self
    facing.names[name] = self
  end,

  spin = function(self, num)
    return facing.wrap(self.id + num)
  end,

  reverse = function(self)
    return self:spin(#facing / 2)
  end
}

facing.RIGHT      = dir(    "right", 1, { 1,  0}, 0  )
facing.DOWN_RIGHT = dir("downright", 2, { 1,  1}, 45 )
facing.DOWN       = dir(     "down", 3, { 0,  1}, 90 )
facing.DOWN_LEFT  = dir( "downleft", 4, {-1,  1}, 135)
facing.LEFT       = dir(     "left", 5, {-1,  0}, 180)
facing.UP_LEFT    = dir(   "upleft", 6, {-1, -1}, 225)
facing.UP         = dir(       "up", 7, { 0, -1}, 270)
facing.UP_RIGHT   = dir(  "upright", 8, { 1, -1}, 315)

function facing.fromName(name)
  return facing.names[name:lower()]
end

function facing.wrap(id)
  return facing[((id - 1) % #facing) + 1]
end

function facing.fromAngle(angle)
  return facing.wrap(utils.math.round((angle % 360) / 45) + 1)
end

function facing.fromRad(rad)
  return facing.fromAngle(math.deg(rad))
end

function facing.fromPos(x, y)
  return facing.fromRad(math.atan2(y, x))
end

return facing