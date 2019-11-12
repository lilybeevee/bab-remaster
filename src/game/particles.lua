local particles = Class{
  init = function(self)
    self.count = {}
    self.timers = {}
    self.particles = {}
  end
}

function particles:draw(palette)
  self:updateHearts(0.25, 0.5)

  local removed = {}

  for i,particle in ipairs(self.particles) do
    if particle.removed then
      table.insert(removed, i)
    else
      love.graphics.push()

      love.graphics.translate(particle.x, particle.y)
      love.graphics.scale(particle.scale)
      love.graphics.setColor(palette(particle.color))

      love.graphics.draw(particle.sprite, -particle.sprite:getWidth()/2, -particle.sprite:getHeight()/2)

      love.graphics.pop()
    end
  end

  for i,remove in ipairs(removed) do
    table.remove(self.particles, remove - (i - 1))
  end
end

function particles:updateHearts(delay, chance)
  if self:getDelay("hearts", delay) and math.random() < chance then
    for i = 1, (self.count["hearts"] or 0) do
      print("nyaaa")
      local new_particle = {
        sprite = Assets.sprite("game", "luv"),
        x = math.random() * TILE_SIZE,
        y = math.random() * TILE_SIZE,
        scale = 0.35,
        color = {4, 2}
      }
      local life = 0.75 + (math.random() * 0.25)
      Timer.tween(life, new_particle, {scale = 0}, 'in-expo', function() new_particle.removed = true end)
      table.insert(self.particles, new_particle)
    end
  end
end

function particles:getDelay(name, delay)
  if not self.timers[name] then self.timers[name] = 0 end
  self.timers[name] = self.timers[name] - love.timer.getDelta()
  if self.timers[name] <= 0 then
    self.timers[name] = self.timers[name] + delay
    return true
  end
  return false
end

return particles