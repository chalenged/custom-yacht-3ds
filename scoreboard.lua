Scoreboard = Object.extend(Object)

function Scoreboard.new(self)
  self.scorelist = {}
  self.scroll = 0
  self.limit = 0
  self.pressed = false
end

function Scoreboard.add(self, score)
  table.insert(self.scorelist, score)
end

function Scoreboard.draw(self, dicelist)
  --local totalhigh = 0
  --local total = 0
  for i=1,#self.scorelist do
    local cs = self.scorelist[i]
    cs:draw(0,15+i*SCORE.HEIGHT - self.scroll*SCORE.HEIGHT, dicelist, settled, curplayer)
    --if not cs.low then totalhigh = totalhigh + cs.calc end
    --print(total,": ",totalhigh,": ",cs.calc,": ",cs.name,": ",cs.low)
    --total = total + cs.calc
  end
end

function Scoreboard.press(self,x,y)
  if not self.pressed then 
    if x > SCORE.NAMELEN then
      player = math.floor((x - SCORE.NAMELEN)/SCORE.SEPERATOR)
      if player > totalPlayers then return false end
      --print(player)
    end
    scorenum = math.floor((y - 35 + self.scroll*SCORE.HEIGHT)/SCORE.HEIGHT) + 1
    --print(player,scorenum,#self.scorelist)
    if (#self.scorelist >= scorenum) then
      --print("test",self.scorelist[scorenum].calc)
      local score=self.scorelist[scorenum]
      --print(score.scores[player],": ",player,": ",curplayer)
      if (score.scores[player] == nil and curplayer == player and settled and score.tp < 3) then
        score.scores[player] = score:compare(dicelist,curplayer)
        lastscored = scorenum
        return true
      end
    end
    --print (scorenum)
    self.pressed = true
  end
  return false
end

function Scoreboard.down(self)
  self.scroll = self.scroll + 4
  if self.scroll + 6 >= #self.scorelist then self.scroll = self.scroll - 4 end
end

function Scoreboard.up(self)
  self.scroll = self.scroll - 4
  if self.scroll  < 0 then self.scroll = 0 end
  
end

function Scoreboard.update(self,dlist)
    local totalhigh = 0
    local total = 0
  for i=1,#self.scorelist do
    local cs = self.scorelist[i]
    if cs.tp == 3 then
      if not cs.low then
        --print(cs.name,cs.bonus,cs.value,totalhigh)
        if totalhigh >= cs.bonus then
          cs.scores[curplayer] = cs.value
        end
      else
        if lastscored ~= i-1 and (self.scorelist[i-1].scores[curplayer] or 0) > 0 then --if the last thing to be scored was anything other than the "yacht"
          if (loadstring(self.scorelist[i-1].sequence)()(dlist)) > 0 then -- check if the "yacht" is valid
            cs.scores[curplayer] = (cs.scores[curplayer] or 0) + cs.value
          end
        end
      end
    end
    if (not cs.low) and cs.tp <= 3 and (cs.scores[curplayer] ~= nil) then totalhigh = totalhigh + cs.scores[curplayer] end
    if cs.tp < 4 then total = total + (cs.scores[curplayer] or 0) end
    if cs.low and cs.tp == 4 then cs.scores[curplayer] = totalhigh
    end
    if cs.tp == 4 then cs.scores[curplayer] = total
    end
    --print(cs.low,cs.name,cs.tp,cs.scores[curplayer],total,totalhigh)
  end
end