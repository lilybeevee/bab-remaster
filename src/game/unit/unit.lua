local unit = Class{
  init = function(self, world, data, id)
    self.world = world
    self.data = data
    self.id = id

    self.draw = setmetatable({
      x, y    = self.x, self.y,
      angle   = self.dir.angle,
      scale_x = 1,
      scale_y = 1,
    }, {__call = function(_, self, ...) self:_draw(...) end})
  end,

  data      = {},
  id        = 0,
  x, y      = 0, 0,
  dir       = Facing.RIGHT,
  draw      = {},
  active    = false,
  blocked   = false,

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

function unit:move(x, y, o)
  local o = o or {}

  if not o.tween then
    -- instantly draw at destination
    self.draw.x = x
    self.draw.y = y
  elseif math.abs(self.x - x) < 2 and math.abs(self.y - y) < 2 then
    -- linear interprolate to destination if adjacent
    utils.timer.tween(tostring(self)..":move", 0.1, self.draw, {x = x, y = y})
  else
    -- fade out and fade in at destination if far apart
    utils.timer.tween(tostring(self)..":scale_x", 0.05, self.draw, {scale_x = 0}, "linear", function()
      utils.timer.tween(tostring(self)..":scale_x", 0.05, self.draw, {scale_x = 1})
    end)
    utils.timer.after(tostring(self)..":move", 0.05, function()
      self.draw.x = x
      self.draw.y = y
    end)
  end

  self.x = x
  self.y = y
end

function unit:turn(dir, o)
  local o = o or {}

  if not o.tween or not self.rotate then
    -- instantly set draw rotation
    self.draw.angle = dir.angle
  else
    -- make sure draw angle is within 0-359 range
    self.draw.angle = (self.draw.angle % 360)

    local new_angle = dir.angle

    if math.abs(self.dir.angle - new_angle) ~= 180 then
      -- linear interprolate to target angle

      -- put our target angle close to our current angle
      if self.draw.angle - new_angle > 180 then
        new_angle = new_angle + 360
      elseif new_angle - self.draw.angle > 180 then
        new_angle = new_angle - 360
      end

      utils.timer.tween(tostring(self)..":turn", 0.1, self.draw, {angle = new_angle})
    else
      -- mirror effect if angle difference is exactly 180 degrees
      utils.timer.tween(tostring(self)..":scale_x", 0.05, self.draw, {scale_x = 0}, "linear", function()
        utils.timer.tween(tostring(self)..":scale_x", 0.05, self.draw, {scale_x = 1})
      end)
      utils.timer.after(tostring(self)..":turn", 0.05, function()
        self.draw.angle = new_angle
      end)
    end
  end

  self.dir = dir
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

function unit:_draw()
  for i, thing in ipairs(self.sprite) do
    local sprite = Assets.sprite("game", thing)
    
    if self.frames ~= 1 then
      sprite = Assets.sprite("game", thing .. "_" .. (math.floor(love.timer.getTime()/0.2)%self.frames+1))
    end

    love.graphics.setColor(self:getDrawColor(i))

    love.graphics.push()
    love.graphics.translate(sprite:getWidth()/2, sprite:getHeight()/2)
    if self.rotate then
      love.graphics.rotate(math.rad(self.draw.angle))
    end
    love.graphics.scale(self.draw.scale_x, self.draw.scale_y)
    love.graphics.translate(-sprite:getWidth()/2, -sprite:getHeight()/2)

    love.graphics.draw(sprite)

    love.graphics.pop()
  end

  if self.blocked then
    self.world.palette:setColor(2, 2)
    love.graphics.draw(Assets.sprite("game", "misc", "x"))
  end
end

function unit:getDrawColor(index)
  index = index or 1
  local color = {self.world.palette(self.color[index])}
  local brightness = 1

  if not self.active and self.is_text then
    brightness = 0.33
  end

  local bg = {self.world.palette(0, 4)}
  for i = 1, 3 do
    color[i] = (1 - brightness) * (bg[i] * 0.5) + brightness * color[i]
  end

  return unpack(color)
end

function unit:countRule(verb, prop) return #self.world.rules:match(self, verb, prop) end
function unit:countProperty(prop)   return self:countRule("be", prop)          end
function unit:hasRule(verb, prop)   return self:countRule(verb, prop) > 0      end
function unit:hasProperty(prop)     return self:countProperty(prop)   > 0      end

function unit:dump()
  return tostring(self)
end

return unit