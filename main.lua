local lg = love.graphics

local w, h = lg.getDimensions()
local x, y = w/2, h/2
local s = 1

local numSelected = 0

local tool = 1
local tools = {
  [1] = "height",
  [2] = "texture",
  [3] = "walkable",
} 

local grid = require("grid").new(32,32)

local map = {}

local click = function(x, y)
  local gx, gy = grid:positionToTile(x, y)
  if not map[gx] then
    map[gx] = {}
  end
  if not map[gx][gy] then
    map[gx][gy] = {}
  end
  local tile = map[gx][gy]
  if tool == 1 or tool == 2 then
    tile[tools[tool]] = numSelected
  elseif tool == 3 then
    tile[tools[tool]] = numSelected == 1
  end
end

love.keypressed = function(key)
  if key == "tab" then
    tool = tool + 1
    if tool > #tools then
      tool = 1
    end
  elseif key == "c" then
    if love.keyboard.isScancodeDown("rctrl", "lctrl") then
      local txt = require("string.buffer").encode(map)
      print("out:",tostring(txt))
      love.system.setClipboardText(love.data.encode("string", "base64", txt))
    end
  elseif key == "v" then
    if love.keyboard.isScancodeDown("rctrl", "lctrl") then
      local txt = love.system.getClipboardText()
      local txt = love.data.decode("string", "base64", txt)
      print("in:",tostring(txt))
      map = require("string.buffer").decode(txt)
    end
  elseif tonumber(key) then
    numSelected = tonumber(key)
  end
end

love.draw = function()
  grid:draw(x, y, w, h, s)
end

local drag = false
local clickTime, clickx, clicky
love.mousepressed = function(x, y, button)
  if button == 1 then
    drag = true
    clickx, clicky = x, y
    clickTime = love.timer.getTime()
  end
end

love.mousemoved = function(_,_, dx, dy)
  if drag then
    x = x + dx
    y = y + dy
  end
end

love.mousereleased = function(_,_, button)
  if button == 1 then
    drag = false
    if love.timer.getTime() - clickTime < 0.2 then
      click(clickx, clicky)
    end
  end
end

love.wheelmoved = function(x, y)
  s = s + -y*0.2
  if s < 0.4 then
    s = 0.4
  elseif s > 2 then
    s = 2
  end
end

love.resize = function(_w, _h)
  w, h = _w, _h
end