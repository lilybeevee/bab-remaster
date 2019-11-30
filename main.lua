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
--[[ Input ]] require "src.input.input"

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

main = {}

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
  Input.registerEvents()

  -- set up the input system
  main.registerInputs()

  GameState.switch(game)
end

function love.update(dt)
  Timer.update(dt)
end

function love.keypressed(key)
  Input.keyPressed(key)
end

function love.keyreleased(key)
  Input.keyReleased(key)
end

function main.registerInputs()
  Input.register("undo", Input.Button{
    Input.Button.Key("z")
  })

  Input.register("reset", Input.Button{
    Input.Button.Key("r")
  })

  Input.register("wait", Input.Button{
    Input.Button.Key("space"),
    Input.Button.Key("enter"),
    Input.Button.Key("kp5")
  })

  Input.register("move (p1)", Input.Direction{
    Input.Direction.Keys("d", nil, "s", nil, "a", nil, "w", nil)
  })
  Input.register("move (p2)", Input.Direction{
    Input.Direction.Keys("right", nil, "down", nil, "left", nil, "up", nil)
  })
  Input.register("move (p3)", Input.Direction{
    Input.Direction.Keys("kp6", "kp3", "kp2", "kp1", "kp4", "kp7", "kp8", "kp9")
  })
end