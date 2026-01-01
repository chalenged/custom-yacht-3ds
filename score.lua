Score = Object.extend(Object)

-- score types: {NORMAL = 1, NUMBER = 2, BONUS = 3, TOTAL = 4}

function Score.new(self, name, value, sequence, bonus, low, tp)
  self.name = name
  self.value = value
  self.sequence = sequence
  self.bonus = bonus or 0
  if low == nil then low = true end
  self.low = low -- false=high, true=low
  self.tp = tp or 1
  --self.canvas = love.graphics.newCanvas(SCORE.NAMELEN,SCORE.HEIGHT) -- canvas to prevent text spillover [NOT WORKING]
  self.scores = {}
  if self.tp == 4 then --the type of score, see top of file
    for i=0,5 do
      self.scores[i] = 0
    end
  end
  self.calc = -1
end

function Score.compare(self, dlist, player)
  if (self.scores[player] ~= nil) then return self.scores[player] end --return player's score if they already scored
  if self.calc ~= -1 then return self.calc end --cache the calculation to save processing power, the 3ds is weak
  
  local function numCalc(num) --basic function to count up all of a specific number
    total = 0
    for i, v in pairs(dlist) do
      if v.side == num then total = total + num end
    end
    return total
  end
  print(self.name)
  if self.tp == 2 then
    self.calc = numCalc(self.value)
  elseif self.tp == 1 then
    self.calc = (loadstring(self.sequence)()(dlist))
  elseif self.tp == 3 then --bonuses are scored outside of this function because of their reliance on the scoresheet
    return 0
  end
  return self.calc
end

function Score.draw(self, x,y,dicelist)
  --[[
  --Canvasses do not work properly on LovePotion 3.0.2, and this project crashes on newer dev builds, so canvasses are not available until a fix is pushed. They were here to prevent long names from going too long, but alas, long names will now go too long.
  local oldcanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("line", 0,0, 100,15)
  love.graphics.print(self.name,0,0)
  love.graphics.setCanvas(oldcanvas)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, x,y)
  love.graphics.setBlendMode("alpha")
  ]]
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("line", x,y, SCORE.NAMELEN,SCORE.HEIGHT)
  love.graphics.print(self.name,x,y)
  font = love.graphics.getFont()
  
  for i = 0, totalPlayers do
    
    if curplayer == i and self.scores[i] == nil and self.tp < 3 then --highlight current players available scores
      --printTable(playerColors)
      local col = playerColors[curplayer+1]
      love.graphics.setColor(col[1], col[2], col[3], 1)
      love.graphics.rectangle("fill", x+SCORE.NAMELEN+(i*SCORE.SEPERATOR),y, SCORE.SEPERATOR,SCORE.HEIGHT)
      love.graphics.setColor(1,1,1,1)
    else
      love.graphics.setColor(1,1,1,1)
    end
    love.graphics.rectangle("line", x+SCORE.NAMELEN+(i*SCORE.SEPERATOR),y, SCORE.SEPERATOR,SCORE.HEIGHT)
    --these are supposed to be centered horizontally but on the 3ds it doesn't seem to work the same
    if self.scores[i] == nil then
      if settled and curplayer == i then
        local strr = self:compare(dicelist,i)
        love.graphics.print(strr,x+SCORE.NAMELEN+(i*SCORE.SEPERATOR)+SCORE.SEPERATOR/2-(font:getWidth(strr)/2),y+2)
      else
        if not settled then self.calc = -1 end
        love.graphics.print("-",x+SCORE.NAMELEN+(i*SCORE.SEPERATOR)+SCORE.SEPERATOR/2-(font:getWidth("-")/2),y+2)        
      end
    else
      love.graphics.print(self.scores[i],x+SCORE.NAMELEN+(i*SCORE.SEPERATOR)+SCORE.SEPERATOR/2-(font:getWidth(self.scores[i])/2),y+2)
      
    end
    love.graphics.setColor(1,1,1,1)
    
  end
    love.graphics.setColor(1,1,1,1)
  
end

--function Score.select