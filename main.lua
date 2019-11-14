require "lib.require"
require "src.values"

-- External libraries
GameState = require "lib.hump.gamestate"
Class = require "lib.hump.class"
Timer = require "lib.hump.timer"
json = require "lib.json"

-- Misc imports
Assets = require "src.assets"
Palette = require "src.palette"
utils = require.tree "src.utils"

-- Game imports
game = require "src.states.game"
Map = require "src.game.map"
World = require "src.game.world"
Facing = require "src.game.facing"
UnitData = require "src.game.unit.unitdata"
Unit = require "src.game.unit.unit"
parser = require "src.game.parser"
RuleParser = require "src.game.rules"
MoveManager = require "src.game.movement"
UpdateManager = require "src.game.updates"
ParticleSystem = require "src.game.particles"

function love.load(args)
  --Rules.parse = utils.performance.test(Rules.parse, "parse")
  --utils.words.compare = utils.performance.test(utils.words.compare, "compare")
  
  love.window.setTitle("bab be u - remasteredddd")
  love.graphics.setDefaultFilter("nearest","nearest")
  print("lily's the best <3")
  print("no u <3")
  Assets.load()

  -- Assign Love2D events to the GameState system
  GameState.registerEvents()

  GameState.switch(game)
end

function love.update(dt)
  Timer.update(dt)
end

function startPerformTests()
  start_time = love.timer.getTime()
end