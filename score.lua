Score = Object.extend(Object)

function Score.new(self, name, value, sequence, bonus, low)
  self.name = name
  self.value = value
  self.sequence = sequence
  self.bonus = bonus or 0
  self.low = low or true -- false=high, true=low
  self.canvas = love.graphics.newCanvas(100,15) -- canvas to prevent text spillover
  self.scores = {}
end

function Score.compare(self, dlist)
  
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
  
  -- Recursive function to check possible matches for the pattern. Probably a better way to do this, make a pr if you know any
  function eval(tvars, tseq)
    tvars = tvars or copy(vars)
    tseq = tseq or copy(seq)
    print("tseq:")
    printTable(tseq)
    local curvar = table.remove(tvars) --pop a variable, which one doesn't matter
    for i, k in pairs(nonewlist) do
      print(k.."huh"..#tvars)
      --print(type(tseq))
      for i=1, #tseq do
        if (type(tseq[i])=="string") then tseq[i] = tseq[i]:gsub(curvar,k) end
      end
      if (#tvars == 0) then --if we have used all of the variables
        local tlist = copy(dlist)
        for i=1, #tseq do
          tseq[i] = load("return "..tseq[i])()
      print(tostring(i)..": "..type(tseq[i]))
        end
        return tseq
      else
        eval(copy(tvars),copy(tseq))
      end
      
    end
  end
  printTable(eval())
  --eval()
end

function Score.draw(self, x,y)
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
end