local buffer = {}

local strByte = string.byte

-- A consuming buffer, so storing index is irrelavent
function buffer.new(str)
  local t = {contents = str:sub(2), c = str:sub(1, 1), ln = 1, cr = 0}
  setmetatable(t, {__index = buffer})

  return t
end

function buffer:peek(d)
  d = d or 0
  return self.contents:sub(d + 1, d + 1)
end

function buffer:next()
  local p = self.contents:sub(1, 1)
  self.contents = self.contents:sub(2)
  self.c = p

  if p == "\n" then
    self.ln = self.ln + 1
    self.cr = 0
  else
    self.cr = self.cr + 1
  end

  return p
end

function buffer:hasNext()
  return #self.contents > 0
end

local lexer = {}

local function tokenizeInstruction(buffer)
  local co = buffer.c:match("[a-zA-Z_]+")
  if co then
    local str = ""
    while buffer.c:match("[a-zA-Z0-9_]+") do
      str = str .. buffer.c
      buffer:next()
    end

    return {type="instruction", content=str, lp = buffer.ln}
  end
  return false
end

local escapeLookup = {r="\r", n="\n", b="\b", ["\""]="\"", ["\\"]="\\"}
local function escapeChar(c)
  local l = escapeLookup[c]
  return l and l or c
end

local function tokenizeString(buffer)
  if buffer.c == "\"" then
    local lpos = buffer.ln
    local cpos = buffer.cr

    local its = ""
    local brokeClean = false
    while buffer:hasNext() do
      local c = buffer:next()
      if c == "\"" then
        brokeClean = true
        break
      end
      if c == "\\" then
        c = escapeChar(buffer:next())
      end
      its = its .. c
    end

    if not brokeClean then
      lexer.exception("Unterminated string at "..lpos..":"..cpos)
    end

    buffer:next()
    return {type="string", content=its, lp = buffer.ln}
  else
    return false
  end
end

local symbolLookup = {
  ["{"] = "open-bracket",
  ["}"] = "close-bracket",
  ["("] = "open-arg",
  [")"] = "close-arg",
  [","] = "arg-sep",
  ["->"] = "proceed"
}
local function tokenizeSymbol(buffer)
  local val = symbolLookup[buffer.c]
  if val then
    buffer:next()
    return {type="symbol", content=val, lp = buffer.ln}
  else
    local nxt = buffer:peek()
    val = symbolLookup[buffer.c .. nxt]
    if val then
      buffer:next()
      buffer:next()
      return {type="symbol", content=val, lp = buffer.ln}
    else
      return false
    end
  end
end

local startNum = 48
local function isNum(c)
  local b = strByte(c)
  if b >= startNum and b < startNum + 10 then
    --WOO ITS A NUMBER (or at least part of one)
    return true
  end
end

local function tokenizeNumber(buffer)
  if isNum(buffer.c) or (buffer.c=="-" and isNum(buffer:peek())) then
    local strN = buffer.c
    while buffer:hasNext() and isNum(buffer:next()) do
      strN = strN .. buffer.c
    end
    if not tonumber(strN) then
      lexer.exception("NaN: "..strN)
    end
    return {type="number", content=tonumber(strN), lp = buffer.ln}
  end
  return false
end

local function tokenizeComment(buffer)
  if buffer.c == "-" and buffer:peek() == "-" then
    local str = ""
    while buffer:hasNext() and buffer:peek() ~= "\n" do
      str = str .. buffer:next()
    end
    buffer:next()
    return {type="comment", content=str, lp = buffer.ln}
  end
  return false
end

local function consumeWhitespace(buffer)
  while buffer:hasNext() do
    if buffer.c:find("%s") then
      buffer:next()
    else
      break
    end
  end
end

function lexer.lex(code)
  if #code == 0 then return {} end -- sanity check

  code = code .. " " -- cuz stuff was being munched

  local tList = {}
  local buffer = buffer.new(code)
  local t

  repeat
    local bad = 0
    consumeWhitespace(buffer)

    t = tokenizeComment(buffer)
    if t then table.insert(tList, t) else bad = bad + 1 end

    t = tokenizeString(buffer)
    if t then table.insert(tList, t) else bad = bad + 1 end

    t = tokenizeSymbol(buffer)
    if t then table.insert(tList, t) else bad = bad + 1 end

    t = tokenizeNumber(buffer)
    if t then table.insert(tList, t) else bad = bad + 1 end

    t = tokenizeInstruction(buffer)
    if t then table.insert(tList, t) else bad = bad + 1 end

    if bad == 5 then
      lexer.exception("Unexpected character at "..buffer.ln..":"..buffer.cr)
    end
  until not buffer:hasNext()

  return tList
end

function lexer.exception(msg)
  error(msg, 4)
end

return lexer
