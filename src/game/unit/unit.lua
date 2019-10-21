local unit = Class{
  init = function(self, data, id)
    self.data = data
    self.id = id

    self.draw = setmetatable({
      x, y  = self.x, self.y,
      angle = Facing.angle(self.dir)
    }, {__call = self._draw})
  end,

  data = UnitData{},
  id   = 0,
  x, y = 0, 0,
  dir  = Facing.RIGHT,
  draw = {},

  move = function(self, x, y)
    self.x = x
    self.y = y

    self.draw.x = self.x
    self.draw.y = self.y
  end,

  turn = function(self, dir)
    self.dir = dir % 8

    self.draw.angle = Facing.angle(self.dir)
  end,

  getLayer = function(self)
    if self.is_text then
      return self.layer + 20
    else
      return self.layer
    end
  end,

  _draw = function(_, self, palette)
    local sprite = Assets.sprite('game', self.sprite)

    palette:setColor(self.color)

    love.graphics.translate(sprite:getWidth()/2, sprite:getHeight()/2)
    love.graphics.rotate(math.rad(self.draw.angle))
    love.graphics.translate(-sprite:getWidth()/2, -sprite:getHeight()/2)

    love.graphics.draw(sprite)
  end,

  -- getting key falls back to unitdata if key doesn't exist
  __index = function(self, key)
    if rawget(self, 'data') then
      local data_var = self.data[key]
      if type(data_var) ~= 'function' then
        return data_var
      end
    end
  end
}

return unit