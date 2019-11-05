local unitdata = Class{
  init = function(self, t)
    for k,v in pairs(t) do
      self[k] = v
    end
    -- if "id" is not specified, set id to name
    if t.name and not t.id then
      self.id = t.name
    end
    if t.name and t.name:startsWith("txt_") then
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
  layer = 1,
}

return unitdata