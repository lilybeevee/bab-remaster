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

function string.split(str, delim)
  local result = {}
  while #str > 0 do
    local from, to = str:find(delim)
    if from then
      table.insert(result, str:sub(1, from-1))
      str = str:sub(to+1)
    else
      table.insert(result, str)
      str = ""
    end
  end
  return result
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

function table.get_combinations(tbl, default, i)
  local result = {}
  local any_exists = false
  i = i or 1
  if i > #tbl then return {} end
  local function getNext(current)
    local next_combos, new_exists = table.get_combinations(tbl, default, i+1)
    any_exists = any_exists or new_exists
    if #next_combos == 0 then
      table.insert(result, {current})
    else
      for _,combo in ipairs(next_combos) do
        table.insert(result, {current, unpack(combo)})
      end
    end
  end
  if #tbl[i] > 0 then
    any_exists = true
    for _,v in ipairs(tbl[i]) do
      getNext(v)
    end
  else
    getNext(default)
  end
  if i == 1 and not any_exists then
    return {}, false
  else
    return result, any_exists
  end
end

function table.fill_defaults(tbl, defaults)
  for k,v in pairs(defaults) do
    if not tbl[k] then tbl[k] = v end
  end
  return tbl
end