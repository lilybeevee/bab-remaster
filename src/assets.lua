local assets = {}


local sprites

------------------
-- Asset loaders
------------------

function assets.loadSprites()
  sprites = {}

  local files = utils.fs.recurseFiles('assets/sprites', true, '(.*)%.png')
  for _,file in ipairs(files) do
    sprites[file] = love.graphics.newImage('assets/sprites/'..file..'.png')
    --trace('Loaded image: '..file)
  end
end

------------------
-- Asset getters
------------------

function assets.sprite(...)
  return sprites[table.concat({...},'/')]
end


return assets