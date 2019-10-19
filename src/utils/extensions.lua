-- Returns true if one of the class's parents (or parents parents and so on) is of a certain class
function Class.inherits(class, target)
  if class.__includes then
    if type(class.__includes) == "table" then
      for _,parent in ipairs(class.__includes) do
        if parent:inherits(target) then
          return true
        end
      end
    else
      return class.__includes == target
    end
  end
  return false
end


function string.startsWith(str, val)
  return str:sub(1, #val) == val
end

function string.endsWith(str, val)
  return str:sub(-#val) == val
end