local palette = Class{
  init = function(self, image)
    self.image = image
  end,

  __call = function(self, ...) return self:get(...) end
}

function palette:get(a, b)
  if a and b then
    return self.image:getPixel(a, b)
  else
    return self.image:getPixel(unpack(a))
  end
end

function palette:setColor(...)
  love.graphics.setColor(self:get(...))
end

return palette