local particles = Class{
  init = function(self, world)
    self.world = world
    self.emitters = {}
    self.timers = {}
    self.particles = {}
  end
}

function particles:draw()
  self:updateHearts(0.25, 0.5)

  local removed = {}

  for i,particle in ipairs(self.particles) do
    if particle.removed then
      table.insert(removed, i)
    else
      love.graphics.push()

      love.graphics.translate(particle.x * TILE_SIZE, particle.y * TILE_SIZE)
      love.graphics.scale(particle.scale)
      self.world.palette:setColor(particle.color)

      love.graphics.draw(particle.sprite, -particle.sprite:getWidth()/2, -particle.sprite:getHeight()/2)

      love.graphics.pop()
    end
  end

  for i,remove in ipairs(removed) do
    table.remove(self.particles, remove - (i - 1))
  end
end

function particles:add(name, x, y, w, h)
  if not self.emitters[name] then self.emitters[name] = {} end
  table.insert(self.emitters[name], {x = x, y = y, w = w, h = h})
end

function particles:updateHearts(delay, chance)
  if self:getDelay("hearts", delay) then
    for _,emitter in ipairs(self.emitters["hearts"] or {}) do
      if math.random() < chance then
        local new_particle = {
          sprite = Assets.sprite("game", "luv"),
          x = emitter.x + (math.random() * emitter.w),
          y = emitter.y + (math.random() * emitter.h),
          scale = 0.35,
          color = {4, 2}
        }
        local life = 0.75 + (math.random() * 0.25)
        Timer.tween(life, new_particle, {scale = 0}, 'in-expo', function() new_particle.removed = true end)
        table.insert(self.particles, new_particle)
      end
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