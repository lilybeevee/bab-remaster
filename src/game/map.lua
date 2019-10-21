local map = Class{
  init = function(self, name)
    -- placeholder
    local lvl = json.decode(love.filesystem.read('levels/'..name..'.json'))

    self.units = {}

    self.height = #lvl
    self.width = 0

    for j,row in ipairs(lvl) do
      for i,tile in ipairs(row) do
        self.width = math.max(self.width, i)
        local tiles = type(tile) == 'table' and tile or {tile}
        for _,tile in ipairs(tiles) do
          local data = Assets.unitData(tile)
          if data then
            table.insert(self.units, {x = i-1, y = j-1, data = data})
          end
        end
      end
    end
  end,

  width = 0,
  height = 0,
  units = {},
}

return map