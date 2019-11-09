local performance = {}

performance.id = 0
performance.counts = {}
performance.totals = {}

function performance.start()
  performance.counts = {}
  performance.totals = {}
end

function performance.test(f, id)
  if not id then
    id = performance.id
    performance.id = performance.id + 1
  end
  return function(...)
    local start_time = love.timer.getTime()
    local ret = f(...)
    local end_time = love.timer.getTime()

    performance.counts[id] = (performance.counts[id] or 0) + 1
    performance.totals[id] = (performance.totals[id] or 0) + (end_time-start_time)*1000

    return ret
  end
end

function performance.stop()
  for id,time in pairs(performance.totals) do
    local count = performance.counts[id]
    print(string.format("[%s] Performance: %.4fms | Average: %.4fms | Calls: %d", id, time, (time/count), count))
  end
end

return performance