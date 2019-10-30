-- words? should this file exist? i couldnt come up with somewhere to put this

local words = {}

function words.compare(a, b)
  local nt = false
  local as, bs = a, b
  if a:endsWith("n't") then as = a:sub(-4); nt = not nt end
  if b:endsWith("n't") then bs = b:sub(-4); nt = not nt end

  if a == b then
    -- exact match, yes
    return true
  elseif (a:endsWith("n't") and as == b) or (b:endsWith("n't") and bs == a) then
    -- cancel out directly n't'd things
    return false
  elseif (as == "txt" and b:startsWith("txt_")) or (bs == "txt" and a:startsWith("txt_")) then
    -- txt matches with all text
    return not nt
  elseif (a:startsWith("txt_") and a:endsWith("n't")) or (b:startsWith("txt_") and b:endsWith("n't")) then
    -- txt_babn't only matches with other txt_ that isn't bab
    if not (a:startsWith("txt_") and b:startsWith("txt_")) then
      return false
    elseif as ~= bs then
      return true
    end
  else
    -- hmmm
    return nt
  end
end

return words