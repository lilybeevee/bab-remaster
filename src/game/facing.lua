local facing = {}

facing.RIGHT      = 1
facing.DOWN_RIGHT = 2
facing.DOWN       = 3
facing.DOWN_LEFT  = 4
facing.LEFT       = 5
facing.UP_LEFT    = 6
facing.UP         = 7
facing.UP_RIGHT   = 8

function facing.angle(dir)
  return (dir - 1) * 45
end

function facing.rad(dir)
  return math.rad(facing.angle(dir))
end

return facing