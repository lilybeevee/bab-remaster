GameState = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Timer = require 'lib.hump.timer'
vector = require 'lib.hump.vector'

local game = {}

function love.load(args)
  GameState.registerEvents()
  
  GameState.switch(game)
end

function love.update(dt)
  Timer.update(dt)
end