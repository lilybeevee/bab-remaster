local Rules = Class{
  init = function(self)
    self:clear()
  end,

  rules = {},
  with = {},

  clear = function(self)
    self.rules = {}
    self.with = {}
  end,

  parse = function(self, world)
    self:clear()

    local sentences = Rules.getSentences(world)

    for _,sentence in ipairs(sentences) do
      local rules = Rules.parseSentence(sentence.words, sentence.dir)
      for _,rule in ipairs(rules) do
        self:add(rule)
      end
    end
  end,

  add = function(self, rule)
    table.insert(self.rules, rule)

    for _,unit in ipairs(rule.units) do
      unit.active = true
      
      if not self.with[unit:getText()] then
        self.with[unit:getText()] = {}
      end
      table.insert(self.with[unit:getText()], rule)
    end
  end,

  serialize = function(rule)
    local str = ''

    local function serializeWord(word)
      local str = word.name..' '
      if word.conds and #word.conds > 0 then
        for i,cond in ipairs(word.conds) do
          str=str..serializeWord(cond)..(i < #word.conds and '& ' or '')
        end
      end
      return str
    end

    return serializeWord(rule.subject)..serializeWord(rule.verb)..serializeWord(rule.object)
  end,

  parseSentence = function(sentence, dir)
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
  end,

  getSentences = function(world)
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
      if not found[first.x..','..first.y] then
        found[first.x..','..first.y] = true
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
  end,
  
  getCombinations = function(t, param_)
    -- t = {{tile1 words}, {tile2 words}, (until out of text)}
    -- places the list of words into a full table of phrases (amount of words) long, {{11,21,31,41},{11,21,31,42},{11,21,32,41},...}
    local param = param_ or {}
    local ret = param.ret or {}
    local i = param.i or 1
    if t[i] then
      for _,v in ipairs(t[i]) do
        local current = table.copy(param.current or {})
        table.insert(current, v)
        if t[i+1] then
          Rules.getCombinations(t, {i = i+1, current = current, ret = ret})
        else
          table.insert(ret, current)
        end
      end
    end
    if i == 1 then
      return ret
    end
  end,

  __ipairs = function(self) return ipairs(self.rules) end,
  __index = function(self, key)
    if type(key) == 'number' then
      local rules = rawget(self, 'rules')
      return rules[key]
    end
  end
}

return Rules