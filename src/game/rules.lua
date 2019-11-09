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

  local text_units = self.world:getUnits(function(unit) return unit.is_text end)
  for _,unit in ipairs(text_units) do
    unit.active = false
    unit.blocked = false
  end

  local sentences = rules.getSentences(self.world)

  for _,sentence in ipairs(sentences) do
    local _rules = rules.parseSentence(sentence.words, sentence.dir)
    for _,rule in ipairs(_rules) do
      self:add(rule)
    end
  end

  -- apply all rules from the new_rules table
  self:final()
end

function rules:add(rule)
  -- make sure whatever the rule we're passing in looks like, it doesnt break stuff!
  table.fill_defaults(rule, {
    subject = table.fill_defaults(rule.subject, {conds = {}}),
    verb = table.fill_defaults(rule.verb, {conds = {}}),
    object = table.fill_defaults(rule.object, {conds = {}}),
    units = {},
    dirs = {}
  })

  table.insert(self.rules, rule)

  for _,unit in ipairs(rule.units) do
    unit.active = true
  end

  -- yeah thats it   ╮(￣ω￣;)╭
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
  for i,rule in ipairs(directory) do
    local matched = true

    -- simple string matching first
    if rule.verb.name ~= verb then matched = false end
    if type(subject) == "string" and not utils.words.compare(rule.subject.name, subject) then matched = false end
    if type(object) == "string" and not utils.words.compare(rule.object.name, object) then matched = false end

    -- non-wildcard unit name matching
    if type(subject) == "table" and not utils.words.compare(rule.subject.name, subject.name) then matched = false end
    if type(object) == "table" and not utils.words.compare(rule.object.name, object.name) then matched = false end

    -- non-wildcard unit condition checking
    if type(subject) == "table" and not rules.testConds(rule.subject.conds, subject, self.world) then matched = false end
    if type(object) == "table" and not rules.testConds(rule.object.conds, object, self.world) then matched = false end

    if not matched then
      -- match failed, do nothing
    elseif not finding_units then
      -- not finding wildcard units, return match here
      table.insert(matches, {
        rule = rule,
        units = {
          subject = type(subject) == "table" and subject or nil,
          object = type(object) == "table" and object or nil
        },
        index = i
      })
    else
      -- start matched units tables with any passed in units
      local matched_subjects = {type(subject) == "table" and subject or nil}
      local matched_objects = {type(object) == "table" and object or nil}

      -- find wildcard units for subject
      if subject == ANY_UNIT then
        -- loop through all units in the world with the subject name
        for _,unit in ipairs(self.world:getUnitsByName(rule.subject.name)) do
          -- test conditions before adding
          if rules.testConds(rule.subject.conds, unit, self.world) then
            table.insert(matched_subjects, unit)
          end
        end
        -- stop matching if no units found
        if #matched_subjects == 0 then matched = false end
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
        if #matched_objects == 0 then matched = false end
      end

      -- messily add matches with all subject/object pairs
      if not matched then
        -- didnt find units for one of the unit wildcards, stop here
      elseif #matched_subjects > 0 then
        -- iterate subject units
        for _,subject_unit in ipairs(matched_subjects) do
          if #matched_objects == 0 then
            -- no objects to pair, add match now
            table.insert(matches, {
              rule = rule,
              units = {
                subject = subject_unit
              },
              index = i
            })
          else
            -- pair subject units with object units
            for _,object_unit in ipairs(matched_objects) do
              table.insert(matches, {
                rule = rule,
                units = {
                  subject = subject_unit,
                  object = object_unit
                },
                index = i
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

function rules:final()
  -- custom getNtCount function for sorting
  local function getNtCount(rule)
    local count, verb = utils.words.getNtCount(rule.verb.name)
    -- special case: 'x be notranform' needs to be above 'x be y' but below 'x ben't y'
    if count == 0 and rule.verb.name == "be" and rule.object.name == "notranform" then
      -- but we're sorting by count and 'x ben't y' has a count of 1
      -- which is directly above 'x be y' with a count of 0...
      -- SO WE USE A DECIMAL BC WHY NOT YOU CANT STOP ME NYAHAHAHAA
      count = 0.5
    end
    return count, verb
  end

  -- sort rules table by n't count, to ensure we read them in the correct order
  table.sort(self.rules, function(a, b)
    return getNtCount(a) > getNtCount(b)
  end)

  -- step 1:
  -- cancel out n't'd rules (haha n't'd thats so weird to look at)
  for _,rule in ipairs(self.rules) do
    local nts, verb = getNtCount(rule)
    if nts > 0 then
      -- found more than 1 nt, cancel time

      local conds = {rule.subject.conds or {}, rule.object.conds or {}}
      local has_conds = #conds[1] > 0 or #conds[2] > 0

      -- invert conditions to add to n't'd rules becauuuuse
      -- they can't just be canceled out
      local inverse_conds = {{},{}}
      for i=1,2 do
        for _,cond in ipairs(conds[i]) do
          local new_cond = table.copy(cond)
          if new_cond.name:ends("n't") then
            new_cond.name = new_cond.name:sub(1, -4)
          else
            new_cond.name = new_cond.name .. "n't"
          end
          table.insert(inverse_conds[i], new_cond)
        end
      end

      -- the verb we need to search for: 1 less n't than we have
      local lesser_verb = verb
      for i = 1, nts - 1 do
        lesser_verb = lesser_verb .. "n't"
      end

      -- let's find the rules to cancel!
      local removed_rules = {}
      for i,lesser_rule in ipairs(self.rules) do
        local matched = true

        -- simple string matching~
        if lesser_rule.verb.name ~= lesser_verb then matched = false end
        if not utils.words.compare(lesser_rule.subject.name, rule.subject.name) then matched = false end

        -- ... but special case object to match any object if we're canceling with notranform
        if rule.verb.name == "be" and rule.object.name == "notranform" then
          if not utils.words.isObject(lesser_rule.object.name) then matched = false end
        else
          -- otherwise we just string match again
          if not utils.words.compare(lesser_rule.object.name, rule.object.name) then matched = false end
        end

        -- only cancel if the rule was matched!!!
        if matched then
          -- add inverted conditions to the rule if this is a conditional n't
          if has_conds then
            -- can conds be nonexistent? they shouldn't really
            lesser_rule.subject.conds = lesser_rule.subject.conds or {}
            lesser_rule.object.conds = lesser_rule.object.conds or {}

            table.merge(lesser_rule.subject.conds, inverse_conds[1])
            table.merge(lesser_rule.object.conds, inverse_conds[2])
          end

          -- important case: what if our rules generally matched but
          --   they only match for specific objects?
          -- example: babn't and waln't
          -- so to solve this, we can add an extra condition to the rule name!
          local multi_rule = false
          local multi_rules = {{}, {}}
          if lesser_rule.subject.name ~= rule.subject.name and utils.words.hasMultiple(lesser_rule.subject.name) then
            local inverse_name
            if rule.subject.name:endsWith("n't") then
              inverse_name = rule.subject.name:sub(1, -4)
            else
              inverse_name = rule.subject.name .. "n't"
            end
            lesser_rule.subject.name = lesser_rule.subject.name .. " & " .. inverse_name
            multi_rule = true
          end
          if lesser_rule.object.name ~= rule.object.name and utils.words.hasMultiple(lesser_rule.object.name) then
            local inverse_name
            if rule.object.name:endsWith("n't") then
              inverse_name = rule.object.name:sub(1, -4)
            else
              inverse_name = rule.object.name .. "n't"
            end
            lesser_rule.object.name = lesser_rule.object.name .. " & " .. inverse_name
            multi_rule = true
          end

          -- remove the rule and block the units only if our rule does not have multiple possibilities
          if not has_conds and not multi_rule then
            table.insert(removed_rules, i)

            for _,unit in ipairs(lesser_rule.units) do
              unit.blocked = true
            end
          end
        end
      end

      -- actually remove the rules (we couldnt do this in the other loop bc it'd mess with the loop)
      for i,index in ipairs(removed_rules) do
        -- also subtract i-1 from the index bc removing things will bump down all indexes
        table.remove(self.rules, index - (i - 1))
      end
    end
  end

  -- step 2:
  -- make remaining units unblocked
  -- create the rules.with table
  for _,rule in ipairs(self.rules) do
    for _,unit in ipairs(rule.units) do
      unit.blocked = false

      if not self.with[unit:getText()] then
        self.with[unit:getText()] = {}
      end
      table.insert(self.with[unit:getText()], rule)
    end
  end
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
            for _,combo in ipairs(table.get_combinations(sentence)) do
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