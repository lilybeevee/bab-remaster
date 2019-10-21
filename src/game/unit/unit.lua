local unit = Class{
  init = function(self, data, id)
    self.data = data
    self.id = id

    self.draw = setmetatable({
      x, y  = self.x, self.y,
      angle = self.dir.angle
    }, {__call = self._draw})
  end,

  data = UnitData{},
  id   = 0,
  x, y = 0, 0,
  dir  = Facing.RIGHT,
  draw = {},
  active = false,

  move = function(self, x, y)
    self.x = x
    self.y = y

    self.draw.x = self.x
    self.draw.y = self.y
  end,

  turn = function(self, dir)
    self.dir = dir

    self.draw.angle = self.dir.angle
  end,

  getText = function(self)
    if self.name:startsWith("txt_") then
      return self.name:sub(5)
    else
      return self.name
    end
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

    love.graphics.setColor(self:getDrawColor(palette))

    love.graphics.translate(sprite:getWidth()/2, sprite:getHeight()/2)
    love.graphics.rotate(math.rad(self.draw.angle))
    love.graphics.translate(-sprite:getWidth()/2, -sprite:getHeight()/2)

    love.graphics.draw(sprite)
  end,

  getDrawColor = function(self, palette)
    local color = {palette(self.color)}
    local brightness = 1

    if not self.active and self.is_text then
      brightness = 0.33
    end

    local bg = {palette(0, 4)}
    for i = 1, 3 do
      color[i] = (1 - brightness) * (bg[i] * 0.5) + brightness * color[i]
    end

    return unpack(color)
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