local lSystem = dofile("lib/lSystem.lua")
local funcList = dofile("lib/funcList.lua")
local iterateTimes = { ... }

local startString = "X"
local rules = {
  {
    "X",
    "F-[[X]+X]+F[+FX]-X"
  },{
    "F",
    "FF"
  }
}

local funcs = {
  ["F"] = {funcList.forward, 4},
  ["-"] = {funcList.rotate, -25},
  ["+"] = {funcList.rotate, 25},
  ["["] = {funcList.save},
  ["]"] = {funcList.load}
}

local outString = lSystem.iterate(startString, rules, iterateTimes[1])

for i=1, #outString do
  local currChar = outString:sub(i, i)
  term.write("Carried out [" .. i .. "/" .. #outString .. "] instructions")

  if funcs[currChar] then
    funcs[currChar][1](funcs[currChar][2])
  end
end
