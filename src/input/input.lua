Input = {}
Input.Button = require "src.input.button"
Input.Direction = require "src.input.direction"


Input.registered = {}

Input.state = {}
Input.last_state = {}

function Input.register(name, input)
  Input.registered[name] = input
end

function Input.deregister(name)
  Input.registered[name] = nil
end

function Input.get(name)
  return Input.registered[name]
end

function Input.registerEvents()
  local old_keypressed = love.keypressed
  function love.keypressed(key, ...)
    Input.keyPressed(key)
    old_keypressed(key, ...)
  end

  local old_keyreleased = love.keyreleased
  function love.keyreleased(key, ...)
    Input.keyReleased(key)
    old_keyreleased(key, ...)
  end

  local old_update = love.update
  function love.update(...)
    old_update(...)
    Input.update()
  end
end

function Input.keyPressed(key)
  Input.state[key] = true
end

function Input.keyReleased(key)
  Input.state[key] = nil
end

function Input.update()
  Input.last_state = table.copy(Input.state, true)
end

return Input