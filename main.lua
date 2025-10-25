require('/nest/nest').init({console = "3ds",scale = 1})
require('hue')
anim8 = require 'anim8/anim8'
Object = require 'classic/classic'
require 'dice'
require 'button'
local yaml = require 'lua-yaml/yaml'

local set = yaml.eval([[
Dice: 
  - 12: 30
Scores: 
  - 3 of a kind: 
    - Value: 0 
    - Sequence: x,x,x 
  - 4 of a kind:
    - Value: 0
    - Sequence: x,x,x,x
  - Full House: 
    - Value: 25
    - Sequence: x,x,y,y,y 
  - Small Straight: 
    - Value: 30
    - Sequence: x,x+1.x+2.x+3 
  - Large Straight: 
    - Value: 40
    - Sequence: x,x+1.x+2.x+3,x+4
  - Yacht: 
    - Value: 50
    - Sequence: x,x,x,x,x
    - Bonus: 100
  - Chance: 
    - Value: 0
    - Sequence: x
Bonus: 
  - Requirement: 63 
  - Value: 35
Rolls: 3
]])

function printTable(table, _count)
  _count = _count or 0
  for i, v in pairs(table) do
    local output = ""
    for i=0,_count do output = output.." " end
    if (type(v) == 'table') then
      if (type(i) ~= 'number') then print(output..i) end
      printTable(v, _count+1)
    else
      print(output..i..": "..v)
    end
  end  
end




local str, font = "Hello World", nil
local textDepth = 6
local time = 0
local diceimage, diceanim
local dicelist = {}
local diceoutline
local maxdice = 24
local dicepage = 1
local buttons = {}
width = 400
height = 240
local dlistoff = 27
local tablesprites = {}
local dicenums = {}
local multidice = false
if (#(set.Dice) > 1) then multidice = true end
for i, v in pairs(set.Dice) do
  for i, v in pairs(set.Dice[i]) do
    print(i.." "..v)
    for j=1,v do
      table.insert(dicenums, tonumber(i))
    end
  end
end
--printTable(dicenums)
function reroll()
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
      end
end



function love.load()
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
    table.insert(buttons, Button(0,32,32,32,reroll))
    table.insert(buttons, Button(0,0,23,32,function()
      dicepage = dicepage - 1
      if (dicepage < 1) then
        dicepage = 1
      end
    end,love.graphics.newImage("assets/arrow.png"),math.pi))
    table.insert(buttons, Button(330-32,0,dlistoff,32,function()
      dicepage = dicepage + 1
      if (dicepage > math.ceil(#dicelist/8)) then
        dicepage = math.ceil(#dicelist/8)
      end
    end,love.graphics.newImage("assets/arrow.png")))
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
  for i, v in pairs(dicelist) do
    v:update(dt)
  end
  if (#touches >= 1) then
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
  -- draw table
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

  for i, v in pairs(dicelist) do
    if (v.sides <= 12) then
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
    if (multidice) then
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
  love.graphics.print(love.timer.getFPS(), 0,0)
  love.graphics.print(str, width/2 - font:getWidth(str)/2, height/2)
end