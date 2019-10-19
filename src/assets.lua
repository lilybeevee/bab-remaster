local assets = {}


local sprites, unitdata, palettes

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

  local files = utils.fs.recurseFiles('assets/sprites', true, '(.*)%.png')
  for _,file in ipairs(files) do
    sprites[file] = love.graphics.newImage('assets/sprites/'..file..'.png')
  end
end

function assets.loadPalettes()
  palettes = {}

  local files = utils.fs.recurseFiles('assets/palettes', true, '(.*)%.png')
  for _,file in ipairs(files) do
    local palette = {}
    local img = love.image.newImageData('assets/palettes/'..file..'.png')
    for i = 0, img:getWidth()-1 do
      for j = 0, img:getHeight()-1 do
        palette[i..','..j] = {img:getPixel(i, j)}
      end
    end
    print('Loaded palette: ' .. file)
    palettes[file] = palette
  end
end

function assets.loadData()
  unitdata = {}

  local tiles = json.decode(love.filesystem.read('assets/data/tiles.json'))
  for _,data in ipairs(tiles) do
    local udata = UnitData(data)
    if unitdata[udata.id] then
      error('Duplicate tile id: ' .. udata.id)
    else
      unitdata[udata.id] = udata
    end
  end
end

------------------
-- Asset getters
------------------

function assets.sprite(...)
  return sprites[table.concat({...},'/')]
end

function assets.palette(name, x, y)
  return unpack(palettes[name][x..','..y])
end

function assets.unitData(id)
  return unitdata[id]
end

return assets