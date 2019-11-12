local utimer = {}

utimer.timers = {}

function utimer.stop(id)
  if utimer.timers[id] then
    Timer.cancel(utimer.timers[id])
  end
end

function utimer.after(id, ...)
  local handle = Timer.after(...)
  utimer.stop(id)
  utimer.timers[id] = handle
  return handle
end

function utimer.tween(id, ...)
  local handle = Timer.tween(...)
  utimer.stop(id)
  utimer.timers[id] = handle
  return handle
end

return utimer