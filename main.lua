local lg = love.graphics

local w, h = lg.getDimensions()
local x, y = w/2, h/2
local s = 1

local hightSelected = 0

local grid = require("grid").new(32,32)

local map = {}

local px, py = 0,0
local click = function(x, y)
  px, py = x, y
end

love.draw = function()
  grid:draw(x, y, w, h, s)
  lg.circle("fill", px, py, 10)
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
    if love.timer.getTime() - clickTime < 0.12 then
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