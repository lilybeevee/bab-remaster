local palette = Class{
  init = function(self, image)
    self.image = image
  end,

  get = function(self, a, b)
    if a and b then
      return self.image:getPixel(a, b)
    else
      return self.image:getPixel(unpack(a))
    end
  end,

  setColor = function(self, ...)
    love.graphics.setColor(self:get(...))
  end,

  __call = function(self, ...) return self:get(...) end
}

return palette