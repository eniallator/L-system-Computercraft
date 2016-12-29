local lSystem = {}

lSystem.nextIteration = function(startString, rules)
  local endString = ""

  for i=1, #startString do
    local currchar = startString:sub(i,i)

    for j=1, #rules do
      if rules[j][1] == currChar then
        endString = endString .. rules[j][2]
        found = true
        break
      end
    end

    endString = endString .. (found and "" or currChar)
  end

  return endString
end

lSystem.iterate = function(startString, rules, times)
  local outString

  for i=1, times do
    outString = lSystem.nextIteration(outstring or startString, rules)
  end

  return outString
end

return lSystem
