local doTurtle = dofile("lib/doTurtle.lua")

local funcList = {}

local currRotation = 0
local currPosition = {x = 0, y = 0}
local exactNextPosition = {x = 0, y = 0}
local facingDir = "posY"
local saves = {}

local function turnLeft()
  facingDir =
    (facingDir == "posY" and "negX") or
    (facingDir == "negX" and "negY") or
    (facingDir == "negY" and "posX") or
    (facingDir == "posX" and "posY")

  turtle.turnLeft()
end

local function turnRight()
  facingDir =
    (facingDir == "posY" and "posX") or
    (facingDir == "posX" and "negY") or
    (facingDir == "negY" and "negX") or
    (facingDir == "negX" and "posY")

  turtle.turnRight()
end

local function updatePosData()
  exactNextPosition.x = exactNextPosition.x + math.cos(math.rad(currRotation))
  exactNextPosition.y = exactNextPosition.y + math.sin(math.rad(currRotation))
end

local function goForward(times)
  for i=1, math.floor(times + 0.5) do
    doTurtle.forward()
  end
end

local function faceDir(dir)
  while facingDir ~= dir do
    local posXArg = dir == "posX" and facingDir == "posY"
    local posYArg = dir == "posY" and facingDir == "negX"
    local negXArg = dir == "negX" and facingDir == "negY"
    local negYArg = dir == "negY" and facingDir == "posX"

    if posXArg or posYArg or negXArg or negYArg then
      turnRight()

    else
      turnLeft()
    end
  end
end

local function nextPos()
  local xDiff = exactNextPosition.x - currPosition.x
  local yDiff = exactNextPosition.y - currPosition.y

  if xDiff >= 0.5 then
    faceDir("posX")

    while xDiff >= 0.5 do
      goForward(xDiff)
      currPosition.x = currPosition.x + 1
      xDiff = exactNextPosition.x - currPosition.x
    end

  elseif xDiff <= -0.5 then
    faceDir("negX")

    while xDiff <= -0.5 do
      goForward(math.abs(xDiff))
      currPosition.x = currPosition.x - 1
      xDiff = exactNextPosition.x - currPosition.x
    end
  end

  if yDiff >= 0.5 then
    faceDir("posY")

    while yDiff >= 0.5 do
      goForward(yDiff)
      currPosition.y = currPosition.y + 1
      yDiff = exactNextPosition.y - currPosition.y
    end

  elseif yDiff <= -0.5 then
    faceDir("negY")

    while yDiff <= -0.5 do
      goForward(math.abs(yDiff))
      currPosition.y = currPosition.y - 1
      yDiff = exactNextPosition.y - currPosition.y
    end
  end
end

funcList.forward = function(distance)
  for i=1, distance do
    updatePosData()
    doTurtle.placeUp()
    nextPos()
  end
end

funcList.forwardNoPlace = function(distance)
  for i=1, distance do
    updatePosData()
    nextPos()
  end
end

funcList.rotate = function(degrees)
  currRotation = (currRotation + degrees) % 360
end

funcList.save = function()
  table.insert(saves, {
    rotation = currRotation,
    position = {
      currPosition.x,
      currPosition.y
    }
  })
end

funcList.load = function()
  local lastSave = saves[#saves]

  currRotation = lastSave.rotation
  goToPos(lastSave.position)

  table.remove(saves, #saves)
end

return funcList
