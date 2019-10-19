--[[
  bab remastered speciality: a **basic unit class**!

  something i felt was missing from bab, this class should
  define common functionality between objects which can be
  rule manipulated, regardless of the specifics of their
  implementation.

  that was a complicated way of saying: mouse/object shared functionality

  all functions will have a final O argument, this is a
  table for additional arguments to be passed in for units
  to use *if they want* so that different types dont need
  to implement unnecessary arguments

  ***************
  NOTE THAT all of this is currently undecided as im not
  sure yet how property interactions and stuff will work
]]
local unit = Class{
  name  = 'unit',
  data  = UnitData{},
  id    = 0,
  pos   = vector(0,0),
  dir   = Facing.RIGHT,
}

function unit:init(data, id)
  self.data = data
  self.id = id
end

function unit:move(x, y)
  self.pos.x = x
  self.pos.y = y
end

function unit:turn(dir)
  unit.dir = dir % 8
end

-- gets a value of the unit if it's set, otherwise gets the value from the unitdata
function unit:get(key)
  if self[key] == nil then
    return self.data[key]
  else
    return self[key]
  end
end

return unit