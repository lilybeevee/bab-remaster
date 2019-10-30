local rules = Class{
  init = function(self, world)
    self.world = world
    self:clear()
  end,

  rules = {},
  with = {},
  cache = {},

  __ipairs = function(self) return ipairs(self.rules) end,
  __index = function(self, key)
    if type(key) == "number" then
      local rules = rawget(self, "rules")
      return rules[key]
    end
  end
}

function rules:clear()
  self.rules = {}
  self.with = {}
  self.cache = {}
end

function rules:parse()
  self:clear()

  local sentences = rules.getSentences(self.world)

  for _,sentence in ipairs(sentences) do
    local _rules = rules.parseSentence(sentence.words, sentence.dir)
    for _,rule in ipairs(_rules) do
      self:add(rule)
    end
  end
end

function rules:add(rule)
  table.insert(self.rules, rule)

  for _,unit in ipairs(rule.units) do
    unit.active = true
    
    if not self.with[unit:getText()] then
      self.with[unit:getText()] = {}
    end
    table.insert(self.with[unit:getText()], rule)
  end
end

--[[
  General-purpose rule matching function!

  arguments:
    subject : string, Unit, ANY_UNIT, ANY_WORD
    verb    : string
    object  : string, Unit, ANY_UNIT, ANY_WORD

  string arguments:
    Will be compared to the rule part
  Unit arguments:
    Will have their name compared to the rule part & be condition tested
  ANY_UNIT:
    Will return a match for all (condition tested) units with the same name as the rule part
  ANY_WORD:
    General wildcard
  
  returns array of matches, a match looks like:
  {
    rule = (matching rule),
    units = {
      subject = (matching subject unit if subject is Unit or ANY_UNIT),
      object = (matching object unit if object is Unit or ANY_UNIT)
    }
  }

  should be self explanatory but for you old babbers:
    rules:match(ANY_UNIT,"be",ANY_WORD) == matchesRule(nil,"be","?")
]]
function rules:match(subject, verb, object)
  -- simple match cacheing for if the same match is done multiple times
  local cached = self.cache[tostring(subject)..","..tostring(verb)..","..tostring(object)]
  if cached then return cached end

  ---- determines the rules table to search
  -- verbs that aren't 'be' are the least common words, so search that if using a unique verb
  -- otherwise, specific properties are the least common (?) so search for the object next if it's not a unit
  -- lastly search for the subject, or verb if the subject is a unit
  local directory
  if verb ~= "be" then
    directory = self.with[verb]
  elseif type(object) == "string" then
    directory = self.with[object]
  elseif type(subject) == "string" then
    directory = self.with[subject]
  else
    directory = self.with[verb]
  end

  -- if the searching table doesn't exist, there are clearly no matching rules so return here
  if not directory then return {} end

  -- determines if the function should return multiple matches per rule, for wildcard units
  local finding_units = subject == ANY_UNIT or object == ANY_UNIT

  local matches = {}
  for _,rule in ipairs(directory) do
    -- simple string matching first
    if rule.verb.name ~= verb then break end
    if type(subject) == "string" and not utils.words.compare(rule.subject.name, subject) then break end
    if type(object) == "string" and not utils.words.compare(rule.object.name, object) then break end

    -- non-wildcard unit name matching
    if type(subject) == "table" and not utils.words.compare(rule.subject.name, subject.name) then break end
    if type(object) == "table" and not utils.words.compare(rule.object.name, object.name) then break end

    -- non-wildcard unit condition checking
    if type(subject) == "table" and not rules.testConds(rule.subject.conds, subject, self.world) then break end
    if type(object) == "table" and not rules.testConds(rule.object.conds, object, self.world) then break end

    if not finding_units then
      -- not finding wildcard units, return match here
      table.insert(matches, {
        rule = rule,
        units = {
          subject = type(subject) == "table" and subject or nil,
          object = type(object) == "table" and object or nil
        }
      })
    else
      -- start matched units tables with any passed in units
      local matched_subjects = {type(subject) == "table" and subject or nil}
      local matched_objects = {type(object) == "table" and object or nil}

      -- find wildcard units for subject
      if subject == ANY_UNIT then
        -- otherwise, loop through all units in the world with the subject name
        for _,unit in ipairs(self.world:getUnitsByName(rule.subject.name)) do
          -- test conditions before adding
          if rules.testConds(rule.subject.conds, unit, self.world) then
            table.insert(matched_subjects, unit)
          end
        end
        -- stop matching if no units found
        if #matched_subjects == 0 then break end
      end

      -- find wildcard units for object
      if object == ANY_UNIT then
        -- otherwise, loop through all units in the world with the object name
        for _,unit in ipairs(self.world:getUnitsByName(rule.object.name)) do
          -- test conditions before adding
          if rules.testConds(rule.object.conds, unit, self.world) then
            table.insert(matched_objects, unit)
          end
        end
        -- stop matching if no units found
        if #matched_objects == 0 then break end
      end

      ---- messily add matches with all subject/object pairs
      -- since we won't reach this line if any wildcards haven't found a unit
      -- we dont have to check whether or not we're matching here
      if #matched_subjects > 0 then
        -- iterate subject units
        for _,subject_unit in ipairs(matched_subjects) do
          if #matched_objects == 0 then
            -- no objects to pair, add match now
            table.insert(matches, {
              rule = rule,
              units = {
                subject = subject_unit
              }
            })
          else
            -- pair subject units with object units
            for _,object_unit in ipairs(matched_objects) do
              table.insert(matches, {
                rule = rule,
                units = {
                  subject = subject_unit,
                  object = object_unit
                }
              })
            end
          end
        end
      else
        -- subject list is empty, iterate object units instead
        for _,object_unit in ipairs(matched_objects) do
          -- since the subject list is empty, we don't have to attempt to pair them!
          table.insert(matches, {
            rule = rule,
            units = {
              object = subject_unit
            }
          })
        end
      end
    end
  end

  -- cache matches just incase we check the exact same set again
  self.cache[tostring(subject)..","..tostring(verb)..","..tostring(object)] = matches

  return matches
end

---------------------
-- Static Functions
---------------------

function rules.testConds(conds, unit, world)
  -- no conds for now, skip
  return true
end

function rules.serialize(rule)
  local str = ""

  local function serializeWord(word)
    local str = word.name.." "
    if word.conds and #word.conds > 0 then
      for i,cond in ipairs(word.conds) do
        str=str..serializeWord(cond)..(i < #word.conds and "& " or "")
      end
    end
    return str
  end

  return serializeWord(rule.subject)..serializeWord(rule.verb)..serializeWord(rule.object)
end

function rules.parseSentence(sentence, dir)
  local result = {}

  local function addUnits(list, set, dirs, root)
    if root.unit and not set[root.unit] then
      table.insert(list, root.unit)
      set[root.unit] = true
      dirs[root.unit] = root.dir
      if root.conds then
        for _,cond in ipairs(root.conds) do
          addUnits(list, set, dirs, cond)
        end
      end
      if root.others then
        for _,other in ipairs(root.others) do
          addUnits(list, set, dirs, other)
        end
      end
      if root.mods then
        for _,mod in ipairs(root.mods) do
          addUnits(list, set, dirs, mod)
        end
      end
    end
  end

  while #sentence >= 3 do
    local valid, words, rules, extra_words = parser.parse(table.copy(sentence), dir)
    if not valid then
      -- i suppose without rewriting the parser itself we'll keep having to use this hacky slow way of doing it
      valid, words, rules, extra_words = parser.parse(table.copy(sentence), dir, true)
    end

    if valid then
      for _,rule in ipairs(rules) do
        local list = {}
        local set = {}
        local dirs = {}
        for _,word in ipairs(extra_words) do
          addUnits(list, set, dirs, word)
        end
        addUnits(list, set, dirs, rule.subject)
        addUnits(list, set, dirs, rule.verb)
        addUnits(list, set, dirs, rule.object)
        
        table.insert(result, table.merge(rule, {units = list, units_set = set, dirs = dirs}))
      end

      local last_word = sentence[#sentence - #words]
      table.insert(words, 1, last_word)
      sentence = words
    else
      table.remove(sentence, 1)
    end
  end

  return result
end

function rules.getSentences(world)
  local function isText(unit)
    return unit.is_text
  end

  local function getCombinations(tbl, i)
    local result = {}
    i = i or 1
    if i > #tbl then return {} end
    for _,v in ipairs(tbl[i]) do
      local next_combos = getCombinations(tbl, i+1)
      if #next_combos == 0 then
        table.insert(result, {v})
      else
        for _,combo in ipairs(next_combos) do
          table.insert(result, {v, unpack(combo)})
        end
      end
    end
    return result
  end

  local sentences = {}
  local found = {}
  local dirs = {Facing.RIGHT, Facing.DOWN_RIGHT, Facing.DOWN}
  for _,first in ipairs(world.units) do
    if not found[first.x..","..first.y] then
      found[first.x..","..first.y] = true
      for _,dir in ipairs(dirs) do
        local x, y = first.x, first.y
        if #world:getUnitsOnTile(x-dir.x, y-dir.y, isText) == 0 then
          local sentence = {}
          local next_units = world:getUnitsOnTile(x, y, isText)
          while #next_units > 0 do
            local words = {}
            for _,unit in ipairs(next_units) do
              table.insert(words, {
                name = unit:getText(),
                type = unit.types,
                unit = unit,
                dir = dir
              })
            end
            table.insert(sentence, words)
            x, y = x + dir.x, y + dir.y
            next_units = world:getUnitsOnTile(x, y, isText)
          end
          -- only parse sentences with >= 3 words
          if #sentence >= 3 then
            for _,combo in ipairs(getCombinations(sentence)) do
              table.insert(sentences, {words = combo, dir = dir})
            end
          end
        end
      end
    end
  end

  return sentences
end

return rules