require 'lib/require'

GameState = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Timer = require 'lib.hump.timer'
vector = require 'lib.hump.vector'

utils = require.tree 'src/utils'
assets = require 'src/assets'

local game = {}

function love.load(args)
  assets.loadSprites()
  GameState.registerEvents()

  GameState.switch(game)
end

function love.update(dt)
  Timer.update(dt)
end