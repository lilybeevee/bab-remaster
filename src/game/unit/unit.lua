local unit = Class{
  init = function(self, data, id)
    self.data = data
    self.id = id

    self.draw = setmetatable({
      x, y  = self.x, self.y,
      angle = self.dir.angle
    }, {__call = function(_, self, ...) self:_draw(...) end})
    
    self.moves = {}
  end,

  data    = {},
  id      = 0,
  x, y    = 0, 0,
  dir     = Facing.RIGHT,
  draw    = {},
  active  = false,
  blocked = false,
  moves   = {},

  -- getting key falls back to data if key doesn't exist
  __index = function(self, key)
    if rawget(self, "data") then
      local data_var = self.data[key]
      if type(data_var) ~= "function" then
        return data_var
      end
    end
  end,
  __tostring = function(self)
    return "unit("..self.name..":"..self.id..")"
  end
}

function unit:move(x, y)
  self.x = x
  self.y = y

  self.draw.x = self.x
  self.draw.y = self.y
end

function unit:turn(dir)
  self.dir = dir

  self.draw.angle = self.dir.angle
end

function unit:getText()
  if self.name:startsWith("txt_") then
    return self.name:sub(5)
  else
    return self.name
  end
end

function unit:getLayer()
  if self.is_text then
    return self.layer or 20
  else
    return self.layer
  end
end

function unit:_draw(palette)
  for i, something in ipairs(self.sprite) do
    local sprite = Assets.sprite("game", something)

    love.graphics.setColor(self:getDrawColor(palette, i))

    love.graphics.push()
    love.graphics.translate(sprite:getWidth()/2, sprite:getHeight()/2)
    love.graphics.rotate(math.rad(self.draw.angle))
    love.graphics.translate(-sprite:getWidth()/2, -sprite:getHeight()/2)

    love.graphics.draw(sprite)

    love.graphics.pop()
  end

  if self.blocked then
    palette:setColor(2, 2)
    love.graphics.draw(Assets.sprite("game", "misc", "x"))
  end
end

function unit:getDrawColor(palette, index)
  index = index or 1
  local color = {palette(self.color[index])}
  local brightness = 1

  if not self.active and self.is_text then
    brightness = 0.33
  end

  local bg = {palette(0, 4)}
  for i = 1, 3 do
    color[i] = (1 - brightness) * (bg[i] * 0.5) + brightness * color[i]
  end

  return unpack(color)
end

function unit:hasProperty(prop)
  return #game.rules:match(self, "be", prop) > 0
end

function unit:hasRule(verb, prop)
  return #game.rules:match(self, verb, prop) > 0
end

function unit:dump()
  return tostring(self)
end

return unit