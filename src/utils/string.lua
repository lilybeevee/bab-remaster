function string.startsWith(str, val)
  return str:sub(1, #val) == val
end

function string.endsWith(str, val)
  return str:sub(-#val) == val
end