local movement = Class{
  init = function(self, world)
    self.world = world
    self.queue = {}
  end
}

function movement:move(x, y, player)
  self.queue = {}

  --[[
    Stage 1: ICY, ICYYYY
    Stage 2: U, U TOO, U TRES, Y'ALL
    Stage 3: SPOOP, WALK, MOOV (DIR), STALK
    Stage 4: YEET, GO, GOOOO, MOOV
  ]]
  for move_stage = 1, 4 do
    local moving_units = {}

    local function addMover(unit, reason, move)
      move = move or {}
      move.dir = move.dir or unit.dir
      move.times = move.times or 1
      move.reason = reason
      
      if move.rotate == nil then move.rotate = true end

      moving_units[unit] = moving_units[unit] or {}
      table.insert(moving_units[unit], move)
    end

    --[[
      Add all moving units for this stage
    ]]
    if move_stage == 1 then

    elseif move_stage == 2 then
      if x ~= 0 or y ~= 0 then
        -- U
        for _,unit in ipairs(self.world:getUnitsWithProp("u", function(unit) return not unit:hasProperty("slep") end)) do
          local dir = Facing.fromPos(x, y)
          addMover(unit, "u", {dir = dir})
        end
      end
    elseif move_stage == 3 then
      -- SPOOP
      for _,match in ipairs(self.world.rules:match(ANY_UNIT, "spoop", ANY_UNIT)) do
        local spooper = match.units.subject
        local spooped = match.units.object

        local dx, dy = spooped.x - spooper.x, spooped.y - spooper.y

        if math.abs(dx) <= 1 and math.abs(dy) <= 1 and not spooped:hasProperty("slep") then
          if dx == 0 and dy == 0 then
            addMover(spooped, "spoop", {dir = spooper.dir, flip = true})
          else
            addMover(spooped, "spoop", {dir = Facing.fromPos(dx, dy)})
          end
        end
      end
      -- WALK
      for _,unit in ipairs(self.world:getUnitsWithProp("walk", function(unit) return not unit:hasProperty("slep") end)) do
        addMover(unit, "walk", {dir = unit.dir, flip = true})
      end
    elseif move_stage == 4 then
      -- GO
      for _,unit in ipairs(self.world:getUnitsWithProp("go")) do --TODO: make GO units redirect objects on them after all movement
        for _,on in ipairs(self.world:getUnitsOnTile(unit.x, unit.y, function(other) return other ~= unit end)) do
          addMover(on, "go", {dir = unit.dir})
        end
      end
    end

    --[[
      Simultaneous movement algorithm copied from old bab, basically a simple version of Baba's:
        1) Make a list of all things that are moving this stage, moving_units.
        2a) Try to move each of them once. For each success, move it to moving_units_next and set it already_moving with one less move point and an update queued. If there was at least one success, repeat 2 until there are no successes. (During this process, things that are currently moving are considered intangible in canMove.)
        2b) But wait, we're still not done! Flip all walkers that failed to flip, then continue until we once again have no successes. (Flipping still only happens once per turn.)
        2c) Finally, if we had at least one success, everything left is moved to moving_units_next with one less move point and we repeat from 2a. If we had no successes, the stage is totally resolved. doupdate() and unset all current_moving.
    ]]
    local move_tick = 0
    local successes = 1

    while successes > 0 do
      move_tick = move_tick + 1
      successes = 0

      local sub_tick = 0
      local something_moved = true

      while something_moved do
        sub_tick = sub_tick + 1
        something_moved = false

        for unit,moves in pairs(moving_units) do
          -- remove any completed moves
          while #moves > 0 and moves[1].times <= 0 do
            table.remove(moves, 1)
          end
          -- do the first move
          if #moves > 0 then
            local move = moves[1]
            
            local function moveUnit(unit, move)
              local success, movers = self:canMove(unit, move.dir.x, move.dir.y)
              if success then
                self:addMove(unit, {x = move.dir.x, y = move.dir.y, rotate = move.rotate})
                for _,mover in ipairs(movers) do
                  self:addMove(mover, {x = move.dir.x, y = move.dir.y, rotate = true})
                end

                successes = successes + 1
                move.times = move.times - 1
                something_moved = true
              end
              return success
            end
            
            if not moveUnit(unit, move) and move.flip and not unit:hasProperty("stubbn") then
              move.dir = move.dir:reverse()
              self:addMove(unit, {dir = move.dir})
              moveUnit(unit, move)
            end
          else
            moving_units[unit] = nil
          end
        end
      end

      self:applyMoves()
    end
  end
end

function movement:addMove(unit, move)
  self.queue[unit] = self.queue[unit] or {}
  table.insert(self.queue[unit], move)
end

function movement:applyMoves()
  for unit,moves in pairs(self.queue) do
    -- sum up simultaneous movements using the max value in each direction
    local max_x, max_y = 0, 0
    local min_x, min_y = 0, 0

    -- if a movement has a strict direction setting, arbitrarily use the most recent one
    local has_dir = nil
    -- otherwise, if a movement has a turn setting, turn it based on its movement
    local has_rotate = false

    for _,move in ipairs(moves) do
      -- adjust max x if positive x movement, adjust min x if negative x movement
      if move.x and move.x > 0 then max_x = math.max(max_x, move.x or 0) end
      if move.x and move.x < 0 then min_x = math.min(min_x, move.x or 0) end

      -- adjust max y if positive y movement, adjust min y if negative y movement
      if move.y and move.y > 0 then max_y = math.max(max_y, move.y or 0) end
      if move.y and move.y < 0 then min_y = math.min(min_y, move.y or 0) end

      has_dir = move.dir or has_dir
      has_rotate = move.rotate or has_rotate
    end

    -- total up x/y movement and move if non-zero
    local x, y = max_x + min_x, max_y + min_y

    if x ~= 0 or y ~= 0 then
      unit:move(unit.x + x, unit.y + y, {tween = true})
    end

    if has_dir then
      -- strictly set turning
      unit:turn(has_dir, {tween = true})
    elseif has_rotate and (x ~= 0 or y ~= 0) then
      -- automatically turn to the closest angle from the movement offset
      unit:turn(Facing.fromPos(x, y), {tween = true})
    end
  end

  self.queue = {}
end

function movement:canMove(unit, dx, dy, o)
  o = o or {}
  local movers = {}
  local x, y = unit.x + dx, unit.y + dy

  if not self.world:inBounds(x, y) then
    return false, {}
  end
  
  if #self.world:getUnitsOnTile(x, y, function(unit) return unit:hasProperty("nogo") end) > 0 then
    return false, {}
  end

  for _,pushed in ipairs(self.world:getUnitsOnTile(x, y, function(unit) return unit:hasProperty("goawaypls") end)) do
    local push_success, push_movers = self:canMove(pushed, dx, dy)
    if push_success then
      table.insert(movers, pushed)
      table.merge(movers, push_movers)
    else
      return false, {}
    end
  end

  return true, movers
end

return movement