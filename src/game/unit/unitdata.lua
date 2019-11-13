local unitdata = Class{
  init = function(self, t)
    for k,v in pairs(t) do
      self[k] = v
    end
    -- if "id" is not specified, set id to name
    if t.name and not t.id then
      self.id = t.name
    end
    -- if "is_text" is not specified, set to true if name starts with "txt_"
    if t.is_text == nil and t.name:startsWith("txt_") then
      self.is_text = true
    end
    -- converts {'object', 'verb'} type format to {object = true, verb = true}
    if t.types then
      self.types = {}
      for _,type in ipairs(t.types) do
        self.types[type] = true
      end
    end
  end,

  id = "unit",
  name = "unit",
  sprite = "wat",
  is_text = false,
  types = {object = true},
  color = {0, 3},
  painted = {true},
  rotate = false,
  frames = 1,
  layer = 1,
}

function unitdata:clone()
  local o = {}
  for k,v in pairs(self) do
    if type(v) == "table" then
      o[k] = table.copy(v, true)
    elseif type(v) ~= "function" then
      o[k] = v
    end
  end
  return o
end

return unitdata