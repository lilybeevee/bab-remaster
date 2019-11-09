local fs = {}

-- Pattern: lua string.match pattern for files (optional)
function fs.recurseFiles(dir, pattern)
  local lfs = love.filesystem
  local result = {}

  local files = lfs.getDirectoryItems(dir)
  for _,file in ipairs(files) do
    if lfs.getInfo(dir.."/"..file, "directory") then
      local subfiles = fs.recurseFiles(dir.."/".. file, pattern)
      for _,subfile in ipairs(subfiles) do
        table.insert(result, file.."/"..subfile)
      end
    else
      if pattern then
        local match = string.match(file, pattern)
        if match then
          table.insert(result, match)
        end
      else
        table.insert(result, file)
      end
    end
  end

  return result
end


return fs