local map = Class{
  init = function(self, name)
    -- placeholder
    local lvl = json.decode(love.filesystem.read("levels/"..name..".json"))

    self.units = {}

    self.height = #lvl
    self.width = 0

    for j,row in ipairs(lvl) do
      for i,tile in ipairs(row) do
        self.width = math.max(self.width, i)
        local tiles = type(tile) == "table" and tile or {tile}
        for _,tiley in ipairs(tiles) do
          local tiles = {tiley}
          if type(tiley) == "table" then
            tiles = tiley
          end
          for _,tile in ipairs(tiles) do
            local tile_args = tile:split("|")
            local data = Assets.unitData(tile_args[1])
            local dir = Facing.RIGHT
            if tile_args[2] then
              dir = Facing.fromName(tile_args[2]) or Facing.RIGHT
            end
            if data then
              table.insert(self.units, {x = i-1, y = j-1, dir = dir, data = data})
            end
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