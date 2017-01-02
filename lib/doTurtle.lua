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

local function refuel()
  local refueled = false

  for i=1,16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)

      if turtle.refuel(turtle.getItemCount()) then
        refueled = true
      end
    end
  end

  if not refueled then
    print("Out of fuel! put some fuel in my inventory and i will use it.")
    sleep(5)
  end
end

doTurtle.placeUp = function()
  while not selectNextItem() do
    print("Out of blocks!")
    sleep(5)
  end

  while not turtle.placeUp() and not turtle.detectUp() do end
end

doTurtle.forward = function()
  while not turtle.forward() do
    if turtle.getFuelLevel() == 0 then
      refuel()
    end
  end
end

return doTurtle
