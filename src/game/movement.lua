local movement = {}

function movement.doMove(x, y)
  for _,match in ipairs(game.rules:match(ANY_UNIT,"be","u")) do
    local u = match.units.subject
    u:move(u.x + x, u.y + y)
    u:turn(Facing[x..","..y])
  end
end

return movement