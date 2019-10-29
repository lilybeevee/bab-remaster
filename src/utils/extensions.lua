local old_pairs = pairs
local old_ipairs = ipairs
function pairs(t, ...) return (getmetatable(t) and getmetatable(t).__pairs or old_pairs)(t, ...) end
function ipairs(t, ...) return (getmetatable(t) and getmetatable(t).__ipairs or old_ipairs)(t, ...) end

function string.startsWith(str, val)
  return str:sub(1, #val) == val
end

function string.endsWith(str, val)
  return str:sub(-#val) == val
end

function table.copy(table, deep)
  if table == nil then return end
  local new_table = {}
  for k,v in pairs(table) do
    if deep and type(v) == "table" then
      new_table[k] = table.copy(v, true)
    else
      new_table[k] = v
    end
  end
  return setmetatable(new_table, getmetatable(table))
end

function table.dump(tbl, deep)
  if tbl == nil then return "nil" end
  local str = "{"
  for k,v in pairs(tbl) do
    if str ~= "{" then
      str = str .. ", "
    end
    if type(k) == "table" then
      str = str .. "(table)" .. " = "
    elseif type(k) ~= "number" then
      str = str .. k .. " = "
    end
    if type(v) == "table" and v.dump then
      str = str .. v:dump(deep)
    elseif type(v) == "table" and deep then
      str = str .. table.dump(v, true)
    elseif type(v) == "string" then
      str = str .. '"' .. v .. '"'
    else
      str = str .. tostring(v)
    end
  end
  str = str .. "}"
  return str
end

function table.contains(tbl, val)
  for k,v in pairs(tbl) do
    if v == val then return true end
  end
  return false
end

function table.merge(tbl, other)
  if tbl == nil or other == nil then return tbl end
  for k,v in pairs(other) do
    if type(k) == "number" then
      if not table.contains(tbl, v) then
        table.insert(tbl, v)
      end
    elseif tbl[k] ~= nil then
      if type(tbl[k]) == "table" and type(v) == "table" then
        table.merge(tbl[k], v)
      end
    else
      tbl[k] = v
    end
  end
  return tbl
end

function table.remove_value(tbl, value)
  for i,v in ipairs(tbl) do
    if v == value then
      table.remove(tbl, i)
      return
    end
  end
end