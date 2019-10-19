local fs = {}

-- Relative: if true, results do not include the dir (optional)
-- Pattern: lua string.match pattern for files (optional)
function fs.recurseFiles(dir, relative, pattern)
  local lfs = love.filesystem
  local result = {}
  local prefix = relative and '' or dir..'/'

  local files = lfs.getDirectoryItems(dir)
  for _,file in ipairs(files) do
    if lfs.getInfo(dir..'/'..file, 'directory') then
      local subfiles = fs.recurseFiles(dir..'/'.. file, true, pattern)
      for _,subfile in ipairs(subfiles) do
        table.insert(result, prefix..file..'/'..subfile)
      end
    else
      if pattern then
        local match = string.match(file, pattern)
        if match then
          table.insert(result, prefix..match)
        end
      else
        table.insert(result, prefix..file)
      end
    end
  end

  return result
end


return fs