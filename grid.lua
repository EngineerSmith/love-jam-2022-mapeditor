local grid = {}
grid.__index = grid

local lg = love.graphics
local floor = math.floor

grid.new = function(tileW, tileH)
    return setmetatable({
        tileW = tileW, tileH = tileH
    }, grid)
end

grid.setTileSize = function(self, w, h)
    self.tileW, self.tileH = w, h
end

grid.positionToTile = function(self, x, y)
    return floor(x / self.tileW), floor(y / self.tileH)
end

local sign = function(value)
  return value > 0 and 1 or value < 1 and -1 or 0
end

grid.draw = function(self, x, y, w, h, scale)
    str = ""
    lg.setLineWidth(2)
    -- X Line
    lg.setColor(0,1,0)
    lg.line(0, y, w, y)
    -- Y Line
    lg.setColor(1,0,0)
    lg.line(x, 0, x, h)
    -- Dashed Lines
    lg.setLineWidth(math.min(0.8 / (scale * 1.5)), 0.4)
    lg.setColor(.6,.6,.6)
    
    local scaledW = self.tileW * scale
    local scaledH = self.tileH * scale
    
    local offsetX = x % scaledW
    local offsetY = y % scaledH
    
    for i=-scaledW + offsetX, w, scaledW do
        lg.line(i, -sign(y)*y, i, h)
    end
    
    for i=-scaledH + offsetY, h, scaledH do
        lg.line(-sign(x)*x, i, w, i)
    end
    
    lg.setLineWidth(1)
end

return grid