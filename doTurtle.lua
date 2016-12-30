local doTurtle = {}

local function selectNextItem()
  local found

  for i=1, 16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      found = true
      break
    end
  end

  return found
end

doTurtle.placeUp = function()
  while not selectNextItem() do end
  while not turtle.placeup() do end
end

doTurtle.forward = function()
  while not turtle.forward() do end
end

return doTurtle
