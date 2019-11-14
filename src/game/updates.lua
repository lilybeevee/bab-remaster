local updates = Class{
  init = function(self, world)
    self.world = world
  end
}

function updates:updateUnits()
  -- this is where    like   most of the stuff will go i guess
end

function updates:applyVisuals()
  -- update particle emitters
  self.world.particles.emitters = {}
  for _,unit in ipairs(self.world:getUnitsWithProp("qt")) do
    self.world.particles:add("hearts", unit.x, unit.y, 1, 1)
  end
end

return updates