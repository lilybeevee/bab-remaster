local updates = Class{
  init = function(self, world)
    self.world = world
  end
}

function updates:updateUnits()
  --[[ update order:
  gone
  moar
  nuek
  split
  vs
  noswim
  ouch
  hotte
  :(
  fordor
  snacc
  tryagain
  delet
  :o
  2edit
  un:)
  :)
  soko
  creat
  ]]
  
  local destroys = {}
  
  --gone
  for _,unit in ipairs(self.world:getUnitsWithProp("gone")) do
    self.world:removeUnit(unit)
  end
  
  --moar
  
  --nuek
  
  --split
  
  --vs
  
  --noswim
  for _,unit in ipairs(self.world:getUnitsWithProp("noswim")) do
    for _,on in ipairs(self.world:getUnitsOnTile(unit.x, unit.y, function(on) return on ~= unit end)) do
      if true then --flye / ignor checks here
        destroys[unit] = true
        destroys[on] = true
      end
    end
  end
  
  for unit,_ in pairs(destroys) do
    self.world:removeUnit(unit)
  end
  destroys = {}
  
  --ouch
  
  --hotte
  for _,unit in ipairs(self.world:getUnitsWithProp("hotte")) do
    for _,on in ipairs(self.world:getUnitsOnTile(unit.x, unit.y, function(on) return on:hasProperty("fridgd") end)) do
      if true then --flye / ignor checks here
        destroys[on] = true
      end
    end
  end
  
  for unit,_ in pairs(destroys) do
    self.world:removeUnit(unit)
  end
  destroys = {}
  
  -- :(
  for _,unit in ipairs(self.world:getUnitsWithProp(":(")) do
    for _,on in ipairs(self.world:getUnitsOnTile(unit.x, unit.y, function(on) return on:hasProperty("u") end)) do
      if true then --flye / ignor checks here
        destroys[on] = true
      end
    end
  end
  
  for unit,_ in pairs(destroys) do
    self.world:removeUnit(unit)
  end
  destroys = {}
  
  --fordor
  for _,unit in ipairs(self.world:getUnitsWithProp("fordor")) do
    for _,on in ipairs(self.world:getUnitsOnTile(unit.x, unit.y, function(on) return on:hasProperty("nedkee") end)) do
      if true then --flye / ignor checks here
        destroys[unit] = true
        destroys[on] = true
        break
      end
    end
  end
  
  for unit,_ in pairs(destroys) do
    self.world:removeUnit(unit)
  end
  destroys = {}
  
  --snacc
  
  --tryagain
  
  --delet
  
  --:o
  for _,unit in ipairs(self.world:getUnitsWithProp(":o")) do
    for _,on in ipairs(self.world:getUnitsOnTile(unit.x, unit.y, function(on) return on:hasProperty("u") end)) do
      if true then --flye / ignor checks here
        destroys[unit] = true
        break
      end
    end
  end
  
  for unit,_ in pairs(destroys) do
    self.world:removeUnit(unit)
  end
  destroys = {}
  
  --2edit
  
  --un:)
  
  --:)
  
  --soko
  
  --creat
end

function updates:convertUnits()
  local removed = {}
  local conversions = {}

  local function addConversion(unit, name)
    conversions[unit] = conversions[unit] or {}
    table.insert(conversions[unit], name)
  end

  local matches = self.world.rules:match(ANY_UNIT, "ben't", ANY_WORD)
  for _,match in ipairs(matches) do
    if utils.words.compare(match.units.subject.name, match.rule.object.name) then
      addConversion(match.units.subject, nil)
      removed[match.units.subject] = true
    end
  end

  matches = self.world.rules:match(ANY_UNIT, "be", ANY_WORD)
  for _,match in ipairs(matches) do
    if not removed[match.units.subject] then
      if match.rule.object.name ~= match.rule.subject.name and utils.words.isObject(match.rule.object.name) then
        local convert_to = {}
        for name,_ in pairs(self.world.referenced_objects) do
          if utils.words.compare(name, match.rule.object.name) then
            table.insert(convert_to, name)
          end
        end
        for _,name in ipairs(convert_to) do
          addConversion(match.units.subject, name)
        end
      end
    end
  end

  for unit,names in pairs(conversions) do
    self.world:removeUnit(unit, {convert = true})
    for _,name in ipairs(names) do
      self.world:createUnit(unit.x, unit.y, unit.dir, Assets.unitData(name), {convert = true, oob = unit.oob})
    end
  end
end

function updates:applyVisuals()
  -- update particle emitters
  self.world.particles.emitters = {}
  for _,unit in ipairs(self.world:getUnitsWithProp("qt")) do
    self.world.particles:add("hearts", unit.x, unit.y, 1, 1)
  end
end

return updates