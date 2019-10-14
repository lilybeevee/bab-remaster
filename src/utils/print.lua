local colors = require 'lib/ansicolors'

function trace(...)
  print(colors.cyan('[trace] '..table.concat({...},'\t')))
end

function warn(...)
  print(colors.yellow('[warn] '..table.concat({...},'\t')))
end

function verybad(...)
  print(colors.red('[error] '..table.concat({...},'\t')))
end