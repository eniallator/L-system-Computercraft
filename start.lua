local lSystem = dofile("lib/lSystem.lua")
local funcList = dofile("lib/funcList.lua")
local iterateTimes = { ... }

-- Variables for Koch curve
local startString = "f"
local rules = {
  {
    "f",
    "f+f-f-f+f"
  }
}

local funcs = {
  ["f"] = {funcList.forward, 2},
  ["+"] = {funcList.rotate, -90},
  ["-"] = {funcList.rotate, 90}
}

local outString = lSystem.iterate(startString, rules, iterateTimes[1])
print(outString)

for i=1, #outString do
  local currChar = outString:sub(i, i)

  if funcs[currChar] then
    funcs[currChar][1](funcs[currChar][2])
  end
end
