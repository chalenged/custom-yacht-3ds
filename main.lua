require('/nest/nest').init({console = "3ds",scale = 1})
require('hue')
anim8 = require 'anim8/anim8'
Object = require 'classic/classic'
require 'dice'
require 'button'
require 'score'
local yaml = require 'lua-yaml/yaml'
local maxDice = 6

local set = yaml.eval([[
Dice: 
  - 6: 2
  - 5: 3
Scores: 
  - 3 of a kind: 
    Value: 0 
    Sequence: '
return function(dice)
  list = {}
  largest = 0
  total = 0
  for i, v in pairs(dice) do
    total = total + v.side
    if (list[v.side] == nil) then
      largest = v.side
      list[v.side] = 1
    else
      list[v.side] = list[v.side] + 1
      largest = v.side
    end
  end
  for i, v in pairs(list) do
    if v > list[largest] then
      largest = i
    end
  end
  if list[largest] >= 3 then return total else return 0 end
end
    '
  - 4 of a kind:
    Value: 0
    Sequence: '
return function(dice)
  list = {}
  largest = 0
  total = 0
  for i, v in pairs(dice) do
    total = total + v.side
    if (list[v.side] == nil) then
      largest = v.side
      list[v.side] = 1
    else
      list[v.side] = list[v.side] + 1
      largest = v.side
    end
  end
  for i, v in pairs(list) do
    if v > list[largest] then
      largest = i
    end
  end
  if list[largest] >= 4 then return total else return 0 end
end
    '
  - Full House: 
    Value: 25
    Sequence: '
return function(dice)
  list = {}
  largest = 0
  total = 0
  size = 0
  full = false
  house = false
  for i, v in pairs(dice) do
    total = total + v.side
    if (list[v.side] == nil) then
      largest = v.side
      list[v.side] = 1
    else
      list[v.side] = list[v.side] + 1
      largest = v.side
    end
  end
  for i, v in pairs(list) do
    if v == 3 then
      full = true
    elseif v == 2 then
      house = true
    end
  end
  if (full and house) then return 25 else return 0 end
end
    '
  - Small Straight: 
    Value: 30
    Sequence: '
return function(dice)
  list = {}
  last = -1
  length = 0 
  longest = 0
  for i, v in pairs(dice) do
    if (list[v.side] == nil) then
      list[v.side] = 1
    else
      list[v.side] = list[v.side] + 1
    end
  end
  
  for i, v in pairs(list) do
    if (i == last+1) then
      length = length + 1
      if length > longest then longest = length end
      last = i
    else
      length = 1
      last = i
    end
  end
  if (longest >= 4) then return 30 else return 0 end
end
    '
  - Large Straight: 
    Value: 40
    Sequence: '
return function(dice)
  list = {}
  last = -1
  length = 0 
  longest = 0
  for i, v in pairs(dice) do
    if (list[v.side] == nil) then
      list[v.side] = 1
    else
      list[v.side] = list[v.side] + 1
    end
  end
  
  for i, v in pairs(list) do
    if (i == last+1) then
      length = length + 1
      if length > longest then longest = length end
      last = i
    else
      length = 1
      last = i
    end
  end
  if (longest >= 5) then return 40 else return 0 end
end
    '
  - Yacht: 
    Value: 50
    Sequence: '
return function(dice)
  list = {}
  largest = 0
  total = 0
  for i, v in pairs(dice) do
    total = total + v.side
    if (list[v.side] == nil) then
      largest = v.side
      list[v.side] = 1
    else
      list[v.side] = list[v.side] + 1
      largest = v.side
    end
  end
  for i, v in pairs(list) do
    if v > list[largest] then
      largest = i
    end
  end
  if list[largest] >= 5 then return 50 else return 0 end
end
    '
    Bonus: 100
  - Chance: 
    Value: 0
    Sequence: '
return function(dice)
  total = 0
  for i, v in pairs(dice) do
    total = total + v.side
  end
  return total
end
    '
Bonus: 
  Requirement: 63 
  Value: 35
Rolls: 3
]])

function printTable(table, _count)
  if type(table) ~= 'table' then return print(table) end
  _count = _count or 0
  for i, v in pairs(table) do
    local output = ""
    for i=0,_count do output = output.." " end
    if (type(v) == 'table') then
      print(output..i)
      printTable(v, _count+1)
    else
      print(output..i..": "..tostring(v))
    end
  end  
end

function copy(obj) -- Deep copy a table, courtesy of https://gist.github.com/tylerneylon/81333721109155b2d244
    if type(obj) ~= 'table' then return obj end
    local res = setmetatable({}, getmetatable(obj))
    for k, v in pairs(obj) do res[copy(k)] = copy(v) end
    return res
end

-- duplicate removal courtesy of https://stackoverflow.com/a/20067270
function remDupe(tab)
  local hash = {}
  local res = {}

  for _,v in pairs(tab) do
     if (not hash[v]) then
         res[#res+1] = v
         hash[v] = true
     end
  end
  return res
end
--printTable(set)


local str, font = "Hello World", nil
local textDepth = 6
local time = 0
local diceimage, diceanim
local dicelist, scorelist = {}, {}
local diceoutline
local maxdice = 24
local dicepage, scorepage = 1, 1
local buttons = {}
width = 400
height = 240
local dlistoff = 27
local tablesprites = {}
local dicenums = {}
local multidice = false
local curplayer = 0
local settled = false
if (#set.Dice > 1) then multidice = true end
for i, v in pairs(set.Dice) do
  for i, v in pairs(set.Dice[i]) do --voodoo magic because it's an ordered list so the dice are always the same order
  if maxDice < tonumber(i) then maxDice = i end
    for j=1,v do
      table.insert(dicenums, tonumber(i))
    end
  end
end
--printTable(dicenums)
for i, v in pairs(set.Scores) do
  for j, w in pairs(set.Scores[i])do
    local name = j
    local value = 0
    local bonus = 0
    local sequence = "x"
    --print(i)
    for k, x in pairs(set.Scores[i][j]) do
      if k == "Sequence" then sequence = x
      elseif k == "Value" then value = x
      elseif k == "Bonus" then bonus = x
      end
    end
    table.insert(scorelist, Score(name,value,sequence,bonus,true))
  end
end

function reroll()
    --scorelist[1]:compare(dicelist)
    --[[
  local newlist = {}
  local toRoll = {}
  if (#dicelist == 0) then toRoll = dicenums end
  for i=1,#dicelist do
    if (dicelist[i].selected) then
      table.insert(newlist,dicelist[i])
    else 
      table.insert(toRoll, dicelist[i].sides)
    end
  end
  dicelist = newlist
  for i=1,#toRoll do
    table.insert(dicelist, Dice(toRoll[i],math.random(400-96)+32, math.random(height-96)+32,math.random()*8-4,math.random()*8-4))
  end]]
end



function love.load()
    -- printTable(scorelist)
    diceimage = love.graphics.newImage('assets/dicesix-sheet.png')
    local g = anim8.newGrid(32,32,diceimage:getWidth(), diceimage:getHeight())
    diceanim = anim8.newAnimation(g('1-13',1), 0.1)
    love.graphics.set3D(false)
    diceoutline = love.graphics.newImage("assets/dice-outline.png")
    tablesprites[1] = love.graphics.newImage("assets/felt.png")
    tablesprites[2] = love.graphics.newImage("assets/table-edge.png")
    tablesprites[3] = love.graphics.newImage("assets/table-corner.png")
    font = love.graphics.getFont()
    font2 = love.graphics.newFont(16)
    font3 = love.graphics.newFont(8)
    table.insert(buttons, Button(320-32,55,32,162,reroll))
    table.insert(buttons, Button(0,0,23,32,function()
      dicepage = dicepage - 1
      if (dicepage < 1) then
        dicepage = 1
      end
    end,love.graphics.newImage("assets/arrow.png"),math.pi))
    table.insert(buttons, Button(320-23,0,dlistoff,32,function()
      dicepage = dicepage + 1
      if (dicepage > math.ceil(#dicelist/8)) then
        dicepage = math.ceil(#dicelist/8)
      end
      if (dicepage < 1) then -- this happens if #dicenum is 0, i.e. before rolling
        dicepage = 1
      end
    end,love.graphics.newImage("assets/arrow.png")))
    table.insert(buttons, Button(320-32,23,23,32,function()
      scorepage = scorepage - 1
      if (scorepage < 1) then
        scorepage = 1
      end
    end,love.graphics.newImage("assets/arrow.png"),math.pi*1.5))
    table.insert(buttons, Button(320-23,240-23,23,32,function()
      scorepage = scorepage + 1
      if (scorepage > math.ceil(#dicelist/8)) then
        scorepage = math.ceil(#dicelist/8)
      end
      if (scorepage < 1) then -- this happens if #dicenum is 0, i.e. before rolling
        scorepage = 1
      end
    end,love.graphics.newImage("assets/arrow.png"),math.pi*0.5))
  reroll()
  --printTable(dicelist) -- 4 1 2 1 3
end
local touches = {}

function love.touchpressed(id, x, y, dx, dy, pressure)
    if touches[id] == nil then touches[id] = {x = x, y = y} end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    touches[id] = nil
    for i=1,#dicelist do
      dicelist[i].selecting = false
    end
    for i, v in pairs(buttons) do
      v.clicked = false
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    -- table.insert(touches[id], {x = x, y = y, t = 1, c = math.fmod(time,1)*360})
end

function love.update(dt)
  diceanim:update(dt)
  settled = true -- presume dice are settled until we find one that isn't
  for i, v in pairs(dicelist) do
    v:update(dt)
    if (v.height > 0) then settled = false end
  end
  if (#touches >= 1) then -- only chek button press if screen is being touched
    for i, v in pairs(buttons) do
      if (touches[1].x >= v.x and touches[1].x <= v.x+v.w and touches[1].y >= v.y and touches[1].y < v.y + v.h) then
        v:click()
      end
    end
    if (touches[1].y <= 33) then
      if (touches[1].x <= (8)*33 + dlistoff and touches[1].x > dlistoff) then
        local i = math.ceil((touches[1].x - dlistoff )/33 )
        if i == 0 then i = 1 end
        i = i + (dicepage-1) * 8
        if (i <= #dicelist and not dicelist[i].selecting) then 
          dicelist[i].selected = not dicelist[i].selected
          dicelist[i].selecting = true
        end
      end
    end
  end
  time = time + dt
end

function love.draw(screen)
  --[[
  width, height = love.graphics.getDimensions(screen)
    if screen == "bottom" then
  --==============================
  -- Bottom Screen
  --==============================
    love.graphics.setColor(0.6470588,0.6470588,0.6470588,1)
    love.graphics.rectangle("fill",0,0,width,height)
    for i, v in pairs(buttons) do
      v:draw()
    end
    for i, v in pairs(dicelist) do
        if (i <= dicepage*8 and i > (dicepage-1)*8) then
          if (v.sides <= 12) then
            diceanim:gotoFrame(v.side+1)
          else
            diceanim:gotoFrame(1)
          end
          love.graphics.setColor(1,1,1,1)
          local dicex = 33*((i-1))+1+ dlistoff-((dicepage-1)*33*8)
          diceanim:draw(diceimage, dicex, 1, 0,1,1,0,0,0,0)
          if (v.sides > 12) then 
            love.graphics.setColor(0,0,0,1)
            love.graphics.setFont(font2)
            love.graphics.print(tostring(v.side), dicex+16-(font2:getWidth(tostring(v.side))/2), 1+16-(font2:getHeight(tostring(v.side))/2),0,1,1)
          end
          if (multidice) then
            love.graphics.setFont(font3)
            love.graphics.setColor(.5,0,0,1)  
            love.graphics.print(tostring(v.sides), dicex+30-(font3:getWidth(tostring(v.sides))), 1+30-(font3:getHeight(tostring(v.sides))),0,1,1)     
          end
          love.graphics.setFont(font)     
          if (v.selected) then
            love.graphics.draw(diceoutline, 33*((i-1))+ dlistoff-((dicepage-1)*33*8), 0,0,1,1,0,0,0,0)
          end
        end
    end
    
    -- draw scoresheet --
    love.graphics.print("Category", 0, 32)
    for i=1,#scorelist do
      scorelist[i]:draw(0,32+i*15, dicelist, settled, curplayer)
    end
    for id, touch in pairs(touches) do
        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("fill", touch.x, touch.y, 5)
        love.graphics.print(touch.x..", "..touch.y,touch.x+5,touch.y-5)
    end
      
      return
    end
  --==============================
  -- Top Screen
  --==============================
  -- draw table --
  do
  for i=0,10 do
    for j=0,5 do
      love.graphics.draw(tablesprites[1],32+i*32,32+j*32,0,1,1,0,0)
    end
  end
  for i=0,5 do
    love.graphics.draw(tablesprites[2],width-32,32*i+32,0,1,1,0,0)   
    love.graphics.draw(tablesprites[2],32,32*i+64,math.pi,1,1,0,0) 
  end
  for i=0,10 do
    love.graphics.draw(tablesprites[2],32*i+32,32,1.5*math.pi,1,1,0,0)
    love.graphics.draw(tablesprites[2],32*i+64,height-32,.5*math.pi,1,1,0,0)    
  end
  love.graphics.draw(tablesprites[3],0,32,1.5*math.pi,1,1,0,0)
  love.graphics.draw(tablesprites[3],width-32,0,0,1,1,0,0)
  love.graphics.draw(tablesprites[3],32,height,math.pi,1,1,0,0)
  love.graphics.draw(tablesprites[3],width,height-32,.5*math.pi,1,1,0,0)
  end

  -- draw dice --
  for i, v in pairs(dicelist) do
    if (v.sides <= 12) then -- i only drew 12 pips, use text for numbers larger than that
      diceanim:gotoFrame(v.side+1)
    else
      diceanim:gotoFrame(1)
    end
    diceanim:draw(diceimage, v.x, v.y, 0,1,1,0,0,0,0)
    if (v.sides > 12) then 
      love.graphics.setColor(0,0,0,1)
      love.graphics.setFont(font2)
      love.graphics.print(tostring(v.side), v.x+16-(font2:getWidth(tostring(v.side))/2), v.y+16-(font2:getHeight(tostring(v.side))/2),0,1,1)
    end
    if (multidice) then --if multiple types of dice, show the sides of that dice in the corner to differentiate them. Rerolling a 4 if it's a d4 vs a d6 is pretty big.
      love.graphics.setFont(font3)
      love.graphics.setColor(.5,0,0,1)  
      love.graphics.print(tostring(v.sides), v.x+30-(font3:getWidth(tostring(v.sides))), v.y+30-(font3:getHeight(tostring(v.sides))),0,1,1)     
      love.graphics.setColor(1,1,1,1)  
    end
    love.graphics.setFont(font)    
    if (v.selected) then
      love.graphics.draw(diceoutline, v.x-1, v.y-1,0,1,1,0,0,0,0)
    end
  end
  
  -- Draw text/ui --
  love.graphics.print(love.timer.getFPS(), 0,0)
  love.graphics.print(str, width/2 - font:getWidth(str)/2, height/2)
  love.graphics.print("Settled: "..tostring(settled),0,16)]]
end