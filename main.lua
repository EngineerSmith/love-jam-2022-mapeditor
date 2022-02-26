
local w, h = love.graphics.getDimensions()
local x, y = w/2, h/2

local grid = require("grid").new(32,32)

love.draw = function()
  grid:draw(x, y, w, h, 1)
end

local drag = false
love.mousepressed = function(_,_, button)
  if button == 1 then
    drag = true
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
  end
end

love.resize = function(_w, _h)
  w, h = _w, _h
end