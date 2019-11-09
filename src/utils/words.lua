-- words? should this file exist? i couldnt come up with somewhere to put this

local words = {}

function words.compare(word1, word2)
  local pairs = {word1:split(" & "), word2:split(" & ")}

  local final_result = nil

  local combos = table.get_combinations(pairs)
  for _,combo in ipairs(combos) do
    local a, b = combo[1], combo[2]

    local nt = false
    local as, bs = a, b
    if a:endsWith("n't") then as = a:sub(1, -4); nt = not nt end
    if b:endsWith("n't") then bs = b:sub(1, -4); nt = not nt end

    local function partialCompare(a, as, b, bs, nt)
      local result = nil
      if a == b then
        -- exact match, yes
        result = true
      elseif a:endsWith("n't") and as == b then
        -- cancel out directly n't'd things
        result = false
      elseif as == "txt" and b:startsWith("txt_") then
        -- txt matches with all text
        result = not nt
      elseif words.isObject(as) ~= words.isObject(bs) then
        -- only match objects with objects
        result = false
      elseif a:startsWith("txt_") and a:endsWith("n't") then
        -- txt_babn't only matches with other txt_ that isn't bab
        if not b:startsWith("txt_") then
          result = false
        elseif as ~= bs then
          result = true
        end
      elseif a:endsWith("n't") then
        -- babn't can't match with txt
        if not b:endsWith("n't") then
          if b == "txt" or b:startsWith("txt_") then
            result = false
          elseif as ~= bs then
            result = true
          end
        else
          if bs == "txt" or b:startsWith("txt_") then
            result = true
          elseif as ~= bs then
            result = true
          end
        end
      end
      return (result ~= nil), result
    end

    local success, result = partialCompare(a, as, b, bs, nt)
    if not success then
      success, result = partialCompare(b, bs, a, as, nt)
    end

    if final_result == nil then
      final_result = result or false
    else
      final_result = final_result and result or false
    end
  end

  return final_result or false
end

function words.isObject(name)
  if name:endsWith("n't") then name = name:sub(1, -4) end

  if name == "txt" or name:startsWith("txt_") then
    return true
  else
    local data = Assets.unitDataByName("txt_" .. name)
    return data and data.types.object
  end
end

function words.hasMultiple(word)
  return word == "txt" or (word:endsWith("n't") and words.isObject(word))
end

function words.getNtCount(word)
  local nt_count = 0
  while word:endsWith("n't") do
    word = word:sub(1, -4)
    nt_count = nt_count + 1
  end
  return nt_count, word
end

return words