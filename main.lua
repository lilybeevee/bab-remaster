require 'lib/require'

-- External libraries
GameState = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Timer = require 'lib.hump.timer'
vector = require 'lib.hump.vector'
json = require 'lib.json'

-- Misc imports
Assets = require 'src.assets'
utils = require.tree 'src.utils'

-- Game imports
game = require 'src.states.game'
Map = require 'src.game.map'
Facing = require 'src.game.facing'
UnitData = require 'src.game.unit.unitdata'
Unit = require 'src.game.unit.unit'

function love.load(args)
  love.window.setTitle('bab be u - remasteredddd')
  love.graphics.setDefaultFilter('nearest','nearest')

  Assets.load()

  -- Assign Love2D events to the GameState system
  GameState.registerEvents()
  
  GameState.switch(game)
end

function love.update(dt)
  Timer.update(dt)
end
