local parser = {}

local tabInsert = table.insert
local tabRemove = table.remove
local tabConcat = table.concat

local function consumeToken(tList, tType, tCont, hard)
  if #tList > 0 then -- Sanity check
    local nToken = tabRemove(tList, 1)

    local lkTb = {}
    if type(tType) == "string" then
      tType = {tType}
    end

    for i=1, #tType do
      lkTb[tType[i]] = true
    end

    if not lkTb[nToken.type] then
      if hard then
        error("Expected "..tabConcat(tType, " or ")..", got "..nToken.type.." on line "..nToken.lp)
      else
        return false, nToken
      end
    end

    if tCont then
      if nToken.content ~= tCont then
        if hard then
          error("Expected '"..tabConcat(tType, " or ").."' "..tType..", got '"..nToken.content.."' on line "..nToken.lp)
        else
          return false, nToken
        end
      end
    end

    return true, nToken
  elseif hard then
    error("Expected "..tType..", got EOF")
  end
end

local turtleInstructions = {
  forward = true,
  forwardNoPlace = true,
  rotate = true,
  save = true,
  load = true
}
local function consumeTurtleInstruction(nxt, tList, form)
  local s, instr
  if nxt then
    s, instr = true, nxt
  else
    s, instr = consumeToken(tList, {"instruction", "symbol"}, nil, true)
  end
  if turtleInstructions[instr.content] then
    local oarg = consumeToken(tList, "symbol", "open-arg", true)
    local argoc
    local alist = {}
    repeat
      s, argoc = consumeToken(tList, {"number", "symbol"}, nil, true)
      if argoc.type == "symbol" then
        if argoc.content == "close-arg" then
          return true, instr.content, alist
        elseif argoc.content ~= "arg-sep" then
          error("Unexpected symbol '"..argoc.content.."' on line "..instr.lp)
        end
      else
        tabInsert(alist, argoc.content)
      end
    until argoc.type == "symbol" and argoc.content == "close-arg"
  elseif (instr.type == "symbol" and instr.content == "close-bracket") then
    return false
  elseif instr.type == "symbol" and instr.content ~= "close-bracket" then
    error("Unexpected symbol '"..instr.content.."' on line "..instr.lp)
  else
    error("Unknown turtle instruction '"..instr.content.."' on line "..instr.lp)
  end
end

local instructions = {
  start_string = function(tList, form)
    local succ, ss = consumeToken(tList, "string", nil, true)
    form.ss = ss.content
  end,
  rule = function(tList, form)
    local s, name = consumeToken(tList, "string", nil, true)
    local s, sChek = consumeToken(tList, "symbol", "proceed", true)
    local s, endr = consumeToken(tList, "string", nil, true)

    tabInsert(form.rules, {name.content, endr.content})
  end,
  ["function"] = function(tList, form)
    local s, name = consumeToken(tList, "string", nil, true)
    local s, nxt = consumeToken(tList, {"instruction", "symbol"}, nil, true)

    local parts = {}

    if nxt.type == "symbol" then
      if nxt.content == "open-bracket" then
        while true do
          local s, n, a = consumeTurtleInstruction(nil, tList, form)
          if not s then break end

          tabInsert(parts, {n, a})
        end
      else
        error("Expected 'open-bracket' symbol, got "..nxt.content.." on line "..nxt.lp)
      end
    else
      local s, n, a = consumeTurtleInstruction(nxt, tList, form)
      if s then
        parts = {{n, a}}
      end
    end

    tabInsert(form.funcs, {name.content, parts})
  end
}

function parser.parse(tokenList)
  local form = {ss="", rules={}, funcs={}}

  while #tokenList > 0 do
    local succ, currToken = consumeToken(tokenList, "instruction", nil, false)

    if not succ then
      if currToken.type ~= "comment" then
        error("Expected instruction, got "..currToken.type.." on line "..currToken.lp)
      end
    else
      local ins = instructions[currToken.content]
      if not ins then
        error("Unknown instruction '"..currToken.content.."' on line "..currToken.lp)
      end

      ins(tokenList, form)
    end
  end

  return form
end

return parser
