local assets = {}


local sprites
local unitdata, unitdata_by_name
local palettes

------------------
-- Asset loaders
------------------

function assets.load()
  assets.loadSprites()
  assets.loadPalettes()
  assets.loadData()
end

function assets.loadSprites()
  sprites = {}

  local files = utils.fs.recurseFiles("assets/sprites", "(.*)%.png")
  for _,file in ipairs(files) do
    sprites[file] = love.graphics.newImage("assets/sprites/"..file..".png")
  end
end

function assets.loadPalettes()
  palettes = {}

  local files = utils.fs.recurseFiles("assets/palettes", "(.*)%.png")
  for _,file in ipairs(files) do
    palettes[file] = Palette(love.image.newImageData("assets/palettes/"..file..".png"))
  end
end

function assets.loadData()
  unitdata = {}
  unitdata_by_name = {}

  local files = utils.fs.recurseFiles("assets/data/tiles", "(.*)%.json")
  for _,file in ipairs(files) do
    local tiles = json.decode(love.filesystem.read("assets/data/tiles/"..file..".json"))
    for _,data in ipairs(tiles) do
      local udata = UnitData(data)
      if unitdata[udata.id] then
        error("Duplicate tile id: " .. udata.id)
      else
        unitdata[udata.id] = udata
        unitdata_by_name[udata.name] = udata
      end
    end
  end
end

------------------
-- Asset getters
------------------

-- Path-ifies additional arguments:  assets.sprite("game", "bab") == assets.sprite("game/bab")
function assets.sprite(...)
  return sprites[table.concat({...},"/")]
end

function assets.palette(name)
  return palettes[name]
end

function assets.unitData(id)
  return unitdata[id]
end
function assets.unitDataByName(name)
  return unitdata_by_name[name]
end

return assets