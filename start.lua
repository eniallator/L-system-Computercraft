local lSystem = dofile("lib/lSystem.lua")
local funcList = dofile("lib/funcList.lua")
local lexer = dofile("lib/lexer.lua")
local parser = dofile("lib/parser.lua")

local args = { ... }

if #args < 2 then
  printError("Syntax: "..(shell and shell.getRunningProgram() or "lsystem").." <inputFile> <iterateTimes>")
  return
end

local filename = args[1]
local iterateTimes = tonumber(args[2])

if not fs.exists(filename) then
  printError("File '"..filename.."' does not exist. Check your spelling")
  return
end

if not iterateTimes then
  printError("'"..args[2].."' is not a number")
  return
end

local handle = fs.open(filename, "r")
local data = handle.readAll()
handle.close()

local tokenList = lexer.lex(data)
local outline = parser.parse(tokenList)

local outString = lSystem.iterate(outline.ss, outline.rules, iterateTimes)
print(outString)

for i=1, #outString do
  local currChar = outString:sub(i, i)

  local cFunc
  for i=1, #outline.funcs do
    if outline.funcs[i][1] == currChar then
      for j=1, #outline.funcs[i][2] do
        funcList[outline.funcs[i][2][j][1]](unpack(outline.funcs[i][2][j][2]))
      end
      break
    end
  end
end
