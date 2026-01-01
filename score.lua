Score = Object.extend(Object)

-- score types: {NORMAL = 1, NUMBER = 2, BONUS = 3, TOTAL = 4}

function Score.new(self, name, value, sequence, bonus, low, tp)
  self.name = name
  self.value = value
  self.sequence = sequence
  self.bonus = bonus or 0
  if low == nil then low = true end
  self.low = low -- false=high, true=low cirPrise 
  self.tp = tp or 1
  self.canvas = love.graphics.newCanvas(SCORE.NAMELEN,SCORE.HEIGHT) -- canvas to prevent text spillover
  self.scores = {}
  if self.tp == 4 then
    for i=0,5 do
      self.scores[i] = 0
    end
  end
  self.calc = -1
end

function Score.compare(self, dlist, player)
  if (self.scores[player] ~= nil) then return self.scores[player] end
  if self.calc ~= -1 then return self.calc end --cache the calculation to save processing power, the 3ds is weak
  --print(self.name)
  --[[
  local newlist, vars, seq = {}, {}, {} -- copy the dice list, so we can mess with it
  newlist = copy(dlist)
  --get the numbers that are in the dice list, without dupes, to speed up processing
  do
    local hash = {}
    local res = {}

    for _,v in pairs(newlist) do
       if (not hash[v.side]) then
           res[#res+1] = v.side
           hash[v.side] = true
       end
    end
    nonewlist = res
  end
  self.sequence:gsub("([%w%+%*%-]+)",function(c) table.insert(seq,c) end) -- creates a list sepperated by commas
  self.sequence:gsub("([%w])",function(c) table.insert(vars,c) end) -- get individual variables
  
  vars = remDupe(vars)
  ]]
  
  local function numCalc(num)
    total = 0
    for i, v in pairs(dlist) do
      if v.side == num then total = total + num end
    end
    return total
  end
  if self.tp == 2 then
    self.calc = numCalc(self.value)
  elseif self.tp == 1 then
    print(self.name,self.sequence)
    self.calc = (loadstring(self.sequence)()(dlist))
  elseif self.tp == 3 then
    return 0
  end
  return self.calc
  -- Recursive function to check possible matches for the pattern. Probably a better way to do this, make a pr if you know any
  
  
--  function eval(tvars, tseq)
--    list = {}
--    tvars = tvars or copy(vars)
--    tseq = tseq or copy(seq)
--    --print("tseq:")
--    --printTable(nonewlist)
--    local curvar = table.remove(tvars) --pop a variable, which one doesn't matter
--    for i, k in pairs(nonewlist) do -- for each unique number rolled
--      print(k.."huh"..#tvars)
--      --print(type(tseq))
--      for i=1, #tseq do -- replace current variable letter with current number
--        if (type(tseq[i])=="string") then tseq[i] = tseq[i]:gsub(curvar,k) end
--      end
--      if (#tvars == 0) then --if we have used all of the variables
--        local tlist = copy(dlist)
--        for i=1, #tseq do
--          tseq[i] = load("return "..tseq[i])()
--      --print(tostring(i)..": "..type(tseq[i]))
--      end
--        table.insert(list, tseq)
--        return list
--      else
--        table.insert(list, eval(copy(tvars),copy(tseq)))
--      end
--    end
--    return list
--  end
--  print("here:")
--  printTable(eval())
--  --eval()
end

function Score.draw(self, x,y,dicelist)
  --[[
  --Canvasses do not work properly on LovePotion 3.0.2, and this project crashes on newer dev builds, so canvasses are not available until a fix is pushed. They were here to prevent long names from going too long, but alas, long names will now go to long.
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
    
    if curplayer == i and self.scores[i] == nil and self.tp < 3 then
      --printTable(playerColors)
      local col = playerColors[curplayer+1]
      love.graphics.setColor(col[1], col[2], col[3], 1)
      love.graphics.rectangle("fill", x+SCORE.NAMELEN+(i*SCORE.SEPERATOR),y, SCORE.SEPERATOR,SCORE.HEIGHT)
      love.graphics.setColor(1,1,1,1)
    else
      love.graphics.setColor(1,1,1,1)
    end
    love.graphics.rectangle("line", x+SCORE.NAMELEN+(i*SCORE.SEPERATOR),y, SCORE.SEPERATOR,SCORE.HEIGHT)
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