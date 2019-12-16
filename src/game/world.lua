local world = Class{
  init = function(self, ...)
    self.maps = {...}
    self.units = {}
    self.units_by_name = {}
    self.units_by_tile = {}
    self.converting_units = {}

    self.oob = {}
    self:createUnit(-1000, -1000, Facing.RIGHT, Assets.unitData("bordr"), {oob = true})

    for _,map in ipairs(self.maps) do
      self.width = math.max(self.width, map.width)
      self.height = math.max(self.height, map.height)
      for _,unit in ipairs(map.units) do
        self:createUnit(unit.x, unit.y, unit.dir, unit.data)
      end
    end
    self.generated = {}
    for x = 0, self.width-1 do
      for y = 0, self.height-1 do
        self.generated[x..","..y] = true
      end
    end

    self.palette = Assets.palette("default")

    -- various ,, game stuff
    self.rules = RuleParser(self)
    self.movement = MoveManager(self)
    self.updates = UpdateManager(self)
    self.particles = ParticleSystem(self)
  end,

  palette = nil,
  maps = {},
  units = {},
  units_by_name = {},
  units_by_tile = {},
  drawn_units = {},
  referenced_objects = {},
  max_id = 0,
  width = 0,
  height = 0,

  oob = nil,
  generated = {}
}

function world:createUnit(x, y, dir, data, o)
  o = o or {}

  local unit = Unit(self, data, self:getNextId(o.id))
  unit:move(x, y, {immediate = true})
  unit:turn(dir, {immediate = true})

  self.units[unit.id] = unit
  
  if not self.units_by_name[unit.name] then
    self.units_by_name[unit.name] = {}
  end
  table.insert(self.units_by_name[unit.name], unit)

  if o.oob then
    unit.oob = true
    table.insert(self.oob, unit)
  end

  if not unit.oob then
    if not utils.words.hasMultiple(unit.name) then
      self.referenced_objects[unit.name] = true
    end
    if utils.words.isObject(unit:getText()) and not utils.words.hasMultiple(unit:getText()) then
      self.referenced_objects[unit:getText()] = true
    end
  end

  if o.convert then
    unit.draw.scale_y = 0
    utils.timer.tween(tostring(unit)..":scale_y", 0.1, unit.draw, {scale_y = 1})
  end

  return unit
end

function world:removeUnit(unit_or_id, o)
  o = o or {}

  -- gets the unit's id if the argument is a table(unit), otherwise assumes the argument is an id
  local id = type(unit_or_id) == "table" and unit_or_id.id or unit_or_id

  local unit = self.units[id]
  if not unit then
    print("attempted removal of already removed unit")
    return
  end

  self.units[id] = nil

  if self.units_by_name[unit.name] then
    table.remove_value(self.units_by_name[unit.name], unit)
  end

  if unit.oob then
    table.remove_value(self.oob, unit)
  end

  if o.convert then
    table.insert(self.drawn_units, unit)
    utils.timer.tween(tostring(unit)..":scale_y", 0.1, unit.draw, {scale_y = 0}, "linear", function()
      table.remove_value(self.drawn_units, unit)
    end)
  end
end

function world:getNextId(id)
  if not id then
    self.max_id = self.max_id + 1
    return self.max_id
  else
    self.max_id = math.max(self.max_id, id)
    return id
  end
end

function world:getUnits(filter, o)
  o = o or {}
  local result = {}
  for _,unit in pairs(self.units) do
    if not filter or filter(unit) then
      table.insert(result, unit)
    end
  end
  if o.oob then
    table.merge(result, self:generateOOB(filter))
  end
  return result
end

function world:generateOOB(filter)
  if not self.referenced_objects["bordr"] then return {} end

  local new_units = {}

  local min_x, min_y = self:getFirstOOB()
  local max_x, max_y = self:getLastOOB()

  for x = min_x, max_x do
    for y = min_y, max_y do
      if not self.generated[x..","..y] then
        local do_gen = false
        local return_gen = {}
        for _,oob in ipairs(self.oob) do
          local old_x, old_y = oob.x, oob.y
          oob.x = x
          oob.y = y
          if not filter or filter(oob) then
            do_gen = true
            return_gen[oob] = true
          end
          oob.x = old_x
          oob.y = old_y
        end
        if do_gen then
          self.generated[x..","..y] = true
          for _,oob in ipairs(self.oob) do
            if #self:getUnitsOnTile(x, y, function(unit) return unit.data == oob.data end, {oob = false}) == 0 then
              local new_unit = self:createUnit(x, y, oob.dir, oob.data)
              if return_gen[oob] then
                table.insert(new_units, new_unit)
              end
            end
          end
        end
      end
    end
  end

  return new_units
end

function world:generateOOBFromPos(x, y)
  if not self.referenced_objects["bordr"] then return {} end

  local min_x, min_y = self:getFirstOOB()
  local max_x, max_y = self:getLastOOB()
  
  if x >= min_x and x <= max_x and y >= min_y and y <= max_y and not self.generated[x..","..y] then
    self.generated[x..","..y] = true
    local new_units = {}
    for _,oob in ipairs(self.oob) do
      if #self:getUnitsOnTile(x, y, function(unit) return unit.data == oob.data end, {oob = false}) == 0 then
        table.insert(new_units, self:createUnit(x, y, oob.dir, oob.data))
      end
    end
    return new_units
  else
    return {}
  end
end

function world:resetOOB()
  local min_x, min_y = self:getFirstOOB()
  local max_x, max_y = self:getLastOOB()

  for x = min_x, max_x do
    for y = min_y, max_y do
      if x == min_x or x == max_x or y == min_y or y == max_y then
        self.generated[x..","..y] = false
      end
    end
  end
end

function world:getUnitsOnTile(x, y, filter, o)
  o = o or {}
  local units = {}
  if self.units_by_tile[x..","..y] then
    for _,unit in ipairs(self.units_by_tile[x..","..y]) do
      if unit.x == x and unit.y == y and (not filter or filter(unit)) then
        table.insert(units, unit)
      end
    end
  end
  if o.oob ~= false then
    for _,unit in ipairs(self:generateOOBFromPos(x, y)) do
      if not filter or filter(unit) then
        table.insert(units, unit)
      end
    end
  end
  return units
end

function world:getUnitsByName(name, filter, o)
  return self:getUnits(function(unit)
    return utils.words.compare(name, unit.name) and (not filter or filter(unit))
  end, o)
end

function world:getUnitsWithRule(verb, object, filter, o)
  local result = {}
  for _,match in ipairs(self.rules:match(ANY_UNIT, verb, object, o)) do
    local unit = match.units.subject
    if not filter or filter(unit) then
      table.insert(result, unit)
    end
  end
  return result
end

function world:getUnitsWithProp(prop, filter, o)
  return self:getUnitsWithRule("be", prop, filter, o)
end

function world:inBounds(x, y)
  return x >= 0 and y >= 0 and x < self.width and y < self.height
end

function world:getScale()
  return 2
end

function world:getFirstOOB()
  local x = -math.ceil((love.graphics.getWidth() - (self.width * TILE_SIZE * self:getScale())) / (TILE_SIZE * self:getScale()) / 2) - 1
  local y = -math.ceil((love.graphics.getHeight() - (self.height * TILE_SIZE * self:getScale())) / (TILE_SIZE * self:getScale()) / 2) - 1
  return x, y
end

function world:getLastOOB()
  local x, y = self:getFirstOOB()
  x = self.width - x - 1
  y = self.height - y - 1
  return x, y
end

function world:getFullTileHeight()
  return math.ceil(love.graphics.getHeight() / (self:getScale() * TILE_SIZE))
end

function world:draw()
  self.palette:setColor(0, 4)
  love.graphics.clear(love.graphics.getColor())

  love.graphics.push()
  love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  love.graphics.scale(self:getScale())
  love.graphics.translate(-self.width/2 * TILE_SIZE, -self.height/2 * TILE_SIZE)

  -- draw oob
  table.sort(self.oob, function(a, b)
    return a:getLayer() < b:getLayer()
  end)

  love.graphics.push()
  local oob_min_x, oob_min_y = self:getFirstOOB()
  local oob_max_x, oob_max_y = self:getLastOOB()
  for x = oob_min_x, oob_max_x do
    for y = oob_min_y, oob_max_y do
      if not self.generated[x..","..y] then
        love.graphics.push()
        love.graphics.translate(x * TILE_SIZE, y * TILE_SIZE)
        for _,oob in ipairs(self.oob) do
          oob:draw(self.palette)
        end
        love.graphics.pop()
      end
    end
  end
  love.graphics.pop()

  -- draw units
  local draw_list = {}
  for _,unit in pairs(self.units) do
    if not unit.oob then
      table.insert(draw_list, unit)
    end
  end
  for _,unit in ipairs(self.drawn_units) do
    if not unit.oob then
      table.insert(draw_list, unit)
    end
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

  self.particles:draw()

  love.graphics.pop()
end

return world