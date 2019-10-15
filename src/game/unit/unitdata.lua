local unitdata = Class{
  init = function(self, t)
    for k,v in pairs(t) do
      self[k] = v
    end
    if t.name and not t.id then
      self.id = t.name
    end
  end,

  id = 'unit',
  name = 'unit',
  sprite = 'wat',
  color = {0, 3},
  rotate = false,
  layer = 0,
}

return unitdata