local lg = love.graphics

local w, h = lg.getDimensions()
local x, y = w/2, h/2
print(x, y)
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

local click = function(_x, _y)
  local gx, gy = grid:positionToTile(_x-x, _y-y)
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

local showHeight = false
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
  elseif key == "rshift" or "lshift" then
    showHeight = not showHeight
  end
end

local textures = {
  [0] = {.9,.9,.9},
  [1] = {.2,.5,.8}, -- set colours to match textures generally
  [2] = {.1,.8,.4},
  [3] = {.7,.6,.1},
  [4] = {.5,.1,.7},
  [5] = {.7,.7,.1},
  [6] = {.1,.7,.7},
  [7] = {.7,.1,.7},
  [8] = {.9,.4,.6},
  [9] = {.4,.1,.1},
}

local drawMap = function(x, y, s)
  lg.push()
  lg.translate(x, y)
  for x, xtbl in pairs(map) do
  for y, tile in pairs(xtbl) do
    lg.push("all")
    lg.translate(x * 32*s, y * 32*s)
    local texture = tile.texture
    if texture then
      local c = textures[texture]
      if c then lg.setColor(c) end
    end
    lg.rectangle("fill", 0,0, 32*s,32*s)
    if showHeight and tile.height then
      lg.setColor(1,1,1)
      lg.print(tile.height, 0,0)
    end
    lg.pop()
  end
  end
  lg.pop()
end

lg.setNewFont(20)
love.draw = function()
  drawMap(x, y, s)
  grid:draw(x, y, w, h, s)
  lg.print(("Num: %d\nTool: %s"):format(numSelected, tools[tool]))
end

local drag = false
local clickNDrag = false
local clickNDragRight = false
love.mousepressed = function(_x, _y, button)
  if button == 3 then
    drag = true
  elseif button == 1 then
    click(_x, _y)
    clickNDrag = true
  elseif button == 2 then
    clickNDragRight = true
    local gx, gy = grid:positionToTile(_x-x, _y-y)
    if map[gx] and map[gx][gy] then
      map[gx][gy][tools[tool]] = nil
      local count = 0
      for _, t in ipairs(tools) do
        if map[gx][gy][t] == nil then
          count = count + 1
        end
      end
      if count == #tools then
        map[gx][gy] = nil
      end
    end
  end
end

love.mousemoved = function(_x, _y, dx, dy)
  if drag then
    x = x + dx
    y = y + dy
    print(x, y)
  end
  if clickNDrag then
    click(_x, _y)
  end
  if clickNDragRight then
    local gx, gy = grid:positionToTile(_x-x, _y-y)
    if map[gx] and map[gx][gy] then
      map[gx][gy][tools[tool]] = nil
      local count = 0
      for _, t in ipairs(tools) do
        if map[gx][gy][t] == nil then
          count = count + 1
        end
      end
      if count == #tools then
        map[gx][gy] = nil
      end
    end
  end
end

love.mousereleased = function(_,_, button)
  if button == 3 then
    drag = false
  elseif button == 1 then
    clickNDrag = false
  elseif button == 2 then
    clickNDragRight = false
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