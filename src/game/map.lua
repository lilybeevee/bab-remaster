local map = Class{}

function map:init(name)
  -- placeholder
  local lvl = json.decode(love.filesystem.read('levels/'..name..'.json'))

  self.units = {}

  self.height = #lvl
  self.width = 0

  local current_id = 1
  for i,row in ipairs(lvl) do
    for j,tile in ipairs(row) do
      self.width = math.max(self.width, j)
      local data = Assets.unitData(tile)
      if data then
        local unit = Unit(data, current_id)
        unit.pos = vector(j-1, i-1)
        table.insert(self.units, unit)
        current_id = current_id + 1
      end
    end
  end
end

return map