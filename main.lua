require('/nest/nest').init({console = "3ds",scale = 1})
require('hue')
anim8 = require 'anim8/anim8'
Object = require 'classic/classic'
require 'dice'
require 'button'
require 'score'
require 'scoreboard'
local yaml = require 'lua-yaml/yaml'
local maxDice = 6
love.graphics.set3D(false)


SCORE = {
  SEPERATOR= 31, --distance between each player's scores
  NAMELEN= 100,
  HEIGHT= 20
}

local set = yaml.eval([[
Dice: 
  - 6: 5
Scores: 
  - 3 of a kind: 
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
  --this function comes from https://www.lua.org/pil/19.3.html 
  function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i] ]
      end
    end
    return iter
  end
  for i, v in pairsByKeys(list) do
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
  function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i] ]
      end
    end
    return iter
  end
  for i, v in pairsByKeys(list) do
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
--
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
fileTable = nil
if (love.filesystem.mountFullPath) ~= nil then --will only run on 3ds, to find yamls in the /3ds/custom-yacht-3ds folder
  local success = love.filesystem.mountFullPath("sdmc:/3ds/custom-yacht-3ds", "custom", "read", true)
  fileTable = (love.filesystem.getDirectoryItems("custom"))
else --will only run on pc, to get yamls in the same directory as the game
  fileTable = (love.filesystem.getDirectoryItems(""))
end
yamls = {}

for i,v in pairs(fileTable) do
  if v:find("%.yaml") then
    table.insert(yamls,v)
  end
end

--printTable(yamls)
math.randomseed(os.time())
local str, font = "Hello World", nil
local textDepth = 6
local time = 0
local diceimage, diceanim
local dicelist, scorelist playerbuttons = {}, {}, {}
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
curplayer = 0
settled = false
local joystick = nil
--local tableCanvas = love.graphics.newCanvas(400,240)
local firstDraw = true
local scoreboard = Scoreboard()
local rolls = 3
rolled = false
totalPlayers = 0 -- add one for true number of players
lastscored = -1
playerColors = {{0.4, 0.1, 0.1},{0.1, 0.4, 0.1},{0.1, 0.1, 0.4},{0.4, 0.4, 0.1},{0.4, 0.1, 0.4},{0.1, 0.4, 0.4}}
menu=true
playermenu = false
filemenu = true
font = love.graphics.getFont()
local curfile = 1
local filescroll = 0

function loadYaml()
  if #yamls == 0 then return 0 end
  dicelist, scorelist = {}, {}
  dicepage, scorepage = 1, 1
  dicenums = {}
  multidice = false
  curplayer = 0
  settled = false
  scoreboard = Scoreboard()
  rolls = 3
  rolled = false
  menu = false
  filemenu = false
  if (#set.Dice > 1) then multidice = true end
  for i, v in pairs(set.Dice) do
    for i, v in pairs(set.Dice[i]) do --voodoo magic because it's an ordered list so the dice are always the same order
    if maxDice < tonumber(i) then maxDice = i end
      for j=1,v do
        table.insert(dicenums, tonumber(i))
      end
    end
  end

  for i = 1, maxDice do
    scoreboard:add(Score(tostring(i), i, "return function() return -1 end", nil, false, 2))
  end
  scoreboard:add(Score("Subtotal",4,"return function() return -1 end", nil, false, 4))
  scoreboard:add(Score("Bonus",tonumber(set.Bonus.Value),"return function() return -1 end", tonumber(set.Bonus.Requirement), false, 3))
  --printTable(set.Bonus.Value)

  for i, v in pairs(set.Scores) do
    for j, w in pairs(set.Scores[i])do
      local name = j
      local value = 0
      local bonus = 0
      local sequence = "return function return -1 end" -- initialize to -1 to make error obvious
      --print(i)
      for k, x in pairs(set.Scores[i][j]) do
        if k == "Sequence" then sequence = x
        elseif k == "Value" then value = x
        elseif k == "Bonus" then bonus = x
        end
      end
      scoreboard:add(Score(name,value,sequence,bonus,true))
      if bonus > 0 then
        scoreboard:add(Score("Bonus",tonumber(bonus),"return function() return -1 end",0,true,3))
      end
    end
  end
  --scoreboard:add(Score("Bonus",tonumber(set.Bonus.Value),"return function() return -1 end", tonumber(set.Bonus.Requirement), false, 3))
  scoreboard:add(Score("total",4,"return function() return -1 end", nil, true, 4))

end
loadYaml()
menu=true
playermenu = true
filemenu = false
function reroll()
    --scorelist[1]:compare(dicelist)
  if rolls <= 0 then return 0 end
  if rolled == true and not settled then return 0 end
  rolled = true
  rolls = rolls - 1
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
    -- printTable(scorelist)
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
    diceimage = love.graphics.newImage('assets/dicesix-sheet.png')
    playerbuttonsimg = love.graphics.newImage("assets/playerbuttons.png")
    
    local g = anim8.newGrid(32,32,diceimage:getWidth(), diceimage:getHeight())
    diceanim = anim8.newAnimation(g('1-13',1), 0.1)
    for i=1,6 do
      playerbuttons[i] = love.graphics.newQuad(math.fmod(i-1,2)*120,math.floor((i-1)/2)*50,120,50,playerbuttonsimg)
    end
    
    diceoutline = love.graphics.newImage("assets/dice-outline.png")
    tablesprites[1] = love.graphics.newImage("assets/felt.png")
    tablesprites[2] = love.graphics.newImage("assets/table-edge.png")
    tablesprites[3] = love.graphics.newImage("assets/table-corner.png")
    font = love.graphics.getFont()
    font2 = love.graphics.newFont(16)
    font3 = love.graphics.newFont(8)
    font4 = love.graphics.newFont(32)
    table.insert(buttons, Button(320-32,55,32,162,reroll,love.graphics.newImage("assets/rollbutton.png")))
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
    table.insert(buttons, Button(320-32,23,32,32,function()
          --[[
      scorepage = scorepage - 1
      if (scorepage < 1) then
        scorepage = 1
      end
      ]]
      scoreboard:up()
    end,love.graphics.newImage("assets/arrow.png"),math.pi*1.5))
    table.insert(buttons, Button(320-32,240-23,32,32,function()
      --[[
      scorepage = scorepage + 1
      if (scorepage > math.ceil(#dicelist/8)) then
        scorepage = math.ceil(#dicelist/8)
      end
      if (scorepage < 1) then -- this happens if #dicenum is 0, i.e. before rolling
        scorepage = 1
      end
      ]]
      scoreboard:down()
    end,love.graphics.newImage("assets/arrow.png"),math.pi*0.5))
    for i=1,6 do
      table.insert(buttons, Button(35+math.fmod(i+1,2)*130,35+math.floor((i-1)/2)*60,120,50,function() 
            totalPlayers = i-1
            playermenu = false
            menu = false
            end, playerbuttons[i], 0, true))
    end
    --[[
    for i=1,6 do
      love.graphics.setColor(0.8,0.8,0.8,1)
      love.graphics.setFont(font4)
      love.graphics.rectangle("fill",35+math.fmod(i+1,2)*130,35+math.floor((i-1)/2)*60,120,50)
      love.graphics.setColor(0,0,0,1)
      love.graphics.print(tostring(i),35+math.fmod(i+1,2)*130+55,40+math.floor((i-1)/2)*60)
      love.graphics.setFont(font)
    end
    ]]
  --reroll()
  --printTable(dicelist) -- 4 1 2 1 3
  
end
local touches = {}

function love.touchpressed(id, x, y, dx, dy, pressure)
    if touches[id] == nil then touches[id] = {x = x, y = y} end
    --print(tostring(id[1])..","..tostring(pressure))
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    touches[id] = nil
    for i=1,#dicelist do
      dicelist[i].selecting = false
    end
    for i, v in pairs(buttons) do
      v.clicked = false
    end
    scoreboard.pressed = false
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    -- table.insert(touches[id], {x = x, y = y, t = 1, c = math.fmod(time,1)*360})
end

function love.gamepadpressed(js, bt)
  if bt == "start" then love.event.quit() end
  if (bt == "select" or bt == "back") and not menu then 
    menu = true
    filemenu = true
  end
  if filemenu then
    if bt == "dpdown" then
      curfile = curfile + 1
      if curfile > #yamls then curfile = curfile - 1 end
      if curfile > filescroll + 12 then filescroll = filescroll + 1 end
    elseif bt == "dpup" then
      curfile = curfile - 1
      if curfile <= 0 then curfile = 1 end
      if curfile <= filescroll then filescroll = filescroll - 1 end
    end
    if bt == "a" then
      print(love.filesystem.read(yamls[curfile]))
      set = yaml.eval(love.filesystem.read(yamls[curfile]))
      loadYaml()
      
    end
  end
end

function love.update(dt)
  diceanim:update(dt)
  settled = true -- presume dice are settled until we find one that isn't
  for i, v in pairs(dicelist) do
    v:update(dt)
    if (v.height > 0) then settled = false end
  end
  if rolled == false then settled = false end
  for id, _v in pairs(touches) do -- only chek button press if screen is being touched
    
    if playermenu then
      
    end
    
    if touches[id].x < 320-32 and touches[id].y > 35 and not menu then
      if (scoreboard:press(touches[id].x,touches[id].y,dicelist)) then
        scoreboard:update(dicelist)
        curplayer = curplayer + 1
        if curplayer > totalPlayers then curplayer = 0 end
        rolled = false
        rolls = set.Rolls
        for i, v in pairs(dicelist) do
          v.selected = false
        end
        --reroll()
      end
    end
    
    -- button press checks
    for i, v in pairs(buttons) do
      if (touches[id].x >= v.x and touches[id].x <= v.x+v.w and touches[id].y >= v.y and touches[id].y < v.y + v.h) and (menu == v.menubutton) then
        v:click()
      end
    end
    -- dice selection checks
    if (touches[id].y <= 33 and rolled and settled) then
      if (touches[id].x <= (8)*33 + dlistoff and touches[id].x > dlistoff) then
        local i = math.ceil((touches[id].x - dlistoff )/33 )
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
  love.graphics.setColor(1,1,1,1)
  
  width, height = love.graphics.getDimensions(screen)
    if screen == "bottom" then
  --==============================
  -- Bottom Screen
  --==============================
    love.graphics.setColor(0.6470588,0.6470588,0.6470588,1)
    love.graphics.rectangle("fill",0,0,width,height)
    
    -- draw scoresheet here, to draw over it at the top of the screen
    scoreboard:draw(dicelist)
    
    love.graphics.setColor(0.6470588,0.6470588,0.6470588,1)
    love.graphics.rectangle("fill",0,0,width,35)
    
    for i, v in pairs(buttons) do
      if not v.menubutton then
        v:draw()
      end
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
    --love.graphics.print("Category", 0, 32)
    for id, touch in pairs(touches) do
        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("fill", touch.x, touch.y, 2)
        --love.graphics.print(touch.x..", "..touch.y,touch.x+5,touch.y-5)
    end
    if menu then
      love.graphics.setColor(0,0,0,0.5)
      love.graphics.rectangle("fill",0,0,width,height)
      if playermenu then
        love.graphics.setColor(0.6470588,0.6470588,0.6470588,1)
        love.graphics.rectangle("fill",25,25,320-50,height-50)
        love.graphics.rectangle("fill",0,0,320,50)
        love.graphics.setColor(0,0,0,1)
        love.graphics.setFont(font4)
        love.graphics.print("Number of Players",15,0)
        for i, v in pairs(buttons) do
          if v.menubutton then
            v:draw()
          end
        end
        for i=1,6 do
          --[[
          love.graphics.setColor(0.8,0.8,0.8,1)
          love.graphics.setFont(font4)
          love.graphics.rectangle("fill",35+math.fmod(i+1,2)*130,35+math.floor((i-1)/2)*60,120,50)
          love.graphics.setColor(0,0,0,1)
          love.graphics.print(tostring(i),35+math.fmod(i+1,2)*130+55,40+math.floor((i-1)/2)*60)
          ]]
          love.graphics.setFont(font)
          
        end
      elseif filemenu then
        
      end
    end
    return
    end
  --==============================
  -- Top Screen
  --==============================
  -- draw table --
  
  love.graphics.setColor(1,1,1,1)
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
  --love.graphics.print(love.timer.getFPS(), 0,0)
  str = "Rolls: " .. rolls
  local rollheight = (font:getHeight(str))
  love.graphics.print(str, width/2 - font:getWidth(str)/2, height-rollheight)
  str = "Player: " .. curplayer+1
  love.graphics.print(str, 0.5+width/2 - font:getWidth(str)/2, height-(font:getHeight(str))-rollheight)
  --love.graphics.print("Settled: "..tostring(settled),0,16)
  
  -- Draw file menu
  if filemenu then
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill",0,0,width,height)
    love.graphics.setColor(0.6470588,0.6470588,0.6470588,1)
    love.graphics.rectangle("fill",25,25,400-50,height-50)
    for i,v in pairs(yamls) do
      if not (i <= filescroll or i > 12+filescroll) then
        love.graphics.setColor(1,1,1,1)
        if curfile == i then
          love.graphics.setColor(1,0.3,0.3,1)
          v = "  "..v
        end
        love.graphics.print(v,25,25+(i-1)*15-filescroll*15)
      end
    end
  end
end