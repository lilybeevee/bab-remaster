local Button = Class{
  init = function(self, nodes)
    self.nodes = nodes
  end
}

function Button:pressed()
  for _,node in ipairs(self.nodes) do
    if node:pressed() then
      return true
    end
  end
  return false
end

function Button:down()
  for _,node in ipairs(self.nodes) do
    if node:down() then
      return true
    end
  end
  return false
end

function Button:released()
  for _,node in ipairs(self.nodes) do
    if node:released() then
      return true
    end
  end
  return false
end

function Button:up()
  for _,node in ipairs(self.nodes) do
    if not node:up() then
      return false
    end
  end
  return true
end

Button.Key = Class{
  init = function(self, key)
    self.key = key
  end,

  pressed = function(self)
    return Input.state[self.key] and not Input.last_state[self.key]
  end,
  down = function(self)
    return Input.state[self.key]
  end,
  released = function(self)
    return not Input.state[self.key] and Input.last_state[self.key]
  end,
  up = function(self)
    return not Input.state[self.key]
  end
}

return Button