local facing = {}

facing.RIGHT      = 0
facing.DOWN_RIGHT = 1
facing.DOWN       = 2
facing.DOWN_LEFT  = 3
facing.LEFT       = 4
facing.UP_LEFT    = 5
facing.UP         = 6
facing.UP_RIGHT   = 7

function facing.angle(dir)
  return dir * 45
end

function facing.rad(dir)
  return math.rad(facing.angle(dir))
end

return facing