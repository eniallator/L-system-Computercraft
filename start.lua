helpListLength = 5

local lSystem = dofile("lib/lSystem.lua")
local funcList = dofile("lib/funcList.lua")
local lexer = dofile("lib/lexer.lua")
local parser = dofile("lib/parser.lua")
local algorithmExamples = dofile("lib/algorithmExamples.lua")

local args = { ... }
local progName = shell and shell.getRunningProgram() or "lsystem"

if #args < 2 then
  printError("Syntax: "..progName.." <inputFile> <iterateTimes>\n Or: "..progName.." --example <exampleIndex> \n Or: " .. progName .. " --example list <pageNumber>")
  return
end

local data
local iterateTimes

if args[1] == "--example" then
  if args[2] == "list" then
    local pageNum = tonumber(args[3]) or 1
    local currTbl = algorithmExamples[pageNum]

    if not args[3] or tonumber(args[3]) and currTbl then
      print("Page " .. pageNum .. " of " .. #algorithmExamples .. ":")

      for i=1, #currTbl do
        print(((pageNum - 1) * helpListLength + i) .. ": " .. currTbl[i].name)
      end

      print("To navigate, use:\n" .. progName .. " --example list <pageNumber>")

    else
      printError("Syntax: " .. progName .. " --example list <pageNumber>")
    end

    return
  elseif tonumber(args[2]) and tonumber(args[3])
    and algorithmExamples[math.ceil(args[2] / helpListLength)]
    and algorithmExamples[math.ceil(args[2] / helpListLength)][args[2] % helpListLength] then

    data = algorithmExamples[math.ceil(args[2] / helpListLength)][args[2] % helpListLength].code
    iterateTimes = args[3]

    print(data, iterateTimes)

  else
    printError("Syntax: " .. progName .. " --example <exampleIndex> <iterateTimes>")
    return
  end

else
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
  data = handle.readAll()
  handle.close()
end

local tokenList = lexer.lex(data)
local outline = parser.parse(tokenList)

local outString = lSystem.iterate(outline.ss, outline.rules, iterateTimes)

for i=1, #outString do
  local currChar = outString:sub(i, i)
  local _,y = term.getCursorPos()
  term.setCursorPos(1, y)
  term.write("Carried out [" .. i .. "/" .. #outString .. "] instructions")

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

print()
