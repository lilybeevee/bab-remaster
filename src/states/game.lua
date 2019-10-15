local game = {}

local map, palette

function game:enter()
  self.map = Map('bab')
  self.palette = 'default'
end

function game:draw()
  self:setColor{1, 0}
  love.graphics.clear(love.graphics.getColor())

  love.graphics.push()
  love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  love.graphics.scale(2, 2)

  love.graphics.translate(-self.map.width/2 * 32, -self.map.height/2 * 32)
  self:setColor{0, 4}
  love.graphics.rectangle('fill', 0, 0, self.map.width*32, self.map.height*32)

  for _,unit in ipairs(self.map.units) do
    local sprite = Assets.sprite('game', unit:get('sprite'))
    local dx, dy = unit.pos.x * 32, unit.pos.y * 32
    self:setColor(unit:get('color'))
    love.graphics.draw(sprite, dx, dy)
  end

  love.graphics.pop()
end

function game:setColor(color)
  love.graphics.setColor(Assets.palette(self.palette, unpack(color)))
end

return game