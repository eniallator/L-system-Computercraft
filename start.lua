local lSystem = dofile("lib/lSystem.lua")
local doTurtle = dofile("lib/doTurtle.lua")
local iterateTimes = { ... }

-- Variables for Koch curve
local startString = "f"
local rules = {
  {"f","f+f−f−f+f"}
}

local funcs = {
  ["f"] = function()
    for i=1, 2 do
      doTurtle.forward()
      doTurtle.placeUp()
    end
  end,

  ["+"] = turtle.left,
  ["-"] = turtle.right
}

local outString = lSystem.iterate(startString, rules, iterateTimes[1])
print(outString)

for i=1, #outString do
  local currChar = outString:sub(i, i)

  if funcs[currChar] then
    funcs[currChar]()
  end
end
