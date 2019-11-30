local umath = {}

function umath.round(num)
  return math.floor(num + 0.5)
end

function umath.clamp(num, min, max)
  return math.max(min, math.min(max, num))
end

return umath