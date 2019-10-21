local world = Class{
  init = function(self, ...)
    self.maps = {...}
    self.units = {}

    for _,map in ipairs(self.maps) do
      self.width = math.max(self.width, map.width)
      self.height = math.max(self.height, map.height)
      for _,unit in ipairs(map.units) do
        self:createUnit(unit.x, unit.y, Facing.RIGHT, unit.data)
      end
    end

    self.palette = Assets.palette('default')
  end,

  palette = nil,
  maps = {},
  units = {},
  max_id = 0,
  width = 0,
  height = 0,

  createUnit = function(self, x, y, dir, data, o)
    o = o or {}

    local unit = Unit(data, self:getNextId(o.id))
    unit:move(x, y, {immediate = true})
    unit:turn(dir, {immediate = true})

    self.units[unit.id] = unit

    return unit
  end,

  removeUnit = function(self, unit_or_id)
    -- gets the unit's id if the argument is a table(unit), otherwise assumes the argument is an id
    local id = type(unit_or_id) == "table" and unit_or_id.id or unit_or_id

    local unit = self.units[id]
    if not unit then
      print('attempted removal of already removed unit')
      return
    end

    self.units[id] = nil
  end,

  getNextId = function(self, id)
    if not id then
      self.max_id = self.max_id + 1
      return self.max_id
    else
      self.max_id = math.max(self.max_id, id)
      return id
    end
  end,

  draw = function(self)
    self.palette:setColor{1, 0}
    love.graphics.clear(love.graphics.getColor())
  
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(2, 2)
  
    love.graphics.translate(-self.width/2 * TILE_SIZE, -self.height/2 * TILE_SIZE)
    self.palette:setColor{0, 4}
    love.graphics.rectangle('fill', 0, 0, self.width*TILE_SIZE, self.height*TILE_SIZE)
  
    local draw_list = {}
    for _,unit in ipairs(self.units) do
      table.insert(draw_list, unit)
    end

    table.sort(draw_list, function(a, b)
      return a:getLayer() < b:getLayer()
    end)

    for _,unit in ipairs(draw_list) do
      love.graphics.push()
      love.graphics.translate(unit.draw.x * TILE_SIZE, unit.draw.y * TILE_SIZE)
      unit:draw(self.palette)
      love.graphics.pop()
    end
  
    love.graphics.pop()
  end
}

return world