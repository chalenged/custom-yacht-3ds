Dice = Object.extend(Object)

function Dice.new(self, sides,x,y,xs,ys)
  self.height = 7.5+math.random()*3 --"height" is basically a timer until the number is finalized
  self.sides = sides
  self.x = x
  self.y = y
  --Velocities
  self.xs = xs 
  self.ys = ys
  --randomize starting side
  self.side = math.random(sides)
  self.sideTimer = 0
  --Whether the dice is selected
  self.selected = false
  --used to prevent constant toggling
  self.selecting = false
end

function Dice.update(self, dt)
  --Stop moving when height is 0
  if (self.height <= 0) then 
    self.height = 0
    return
  end
  --move through the sides
  self.sideTimer = self.sideTimer + dt
  if (self.sideTimer >= 0.05) then 
    self.side = self.side + math.floor(self.sideTimer/0.05)
    self.sideTimer = math.modf(self.sideTimer, 0.05)
  end
  --loop the sides
  if (self.side > self.sides) then self.side = 1 end
  self.height = self.height - 3.5*dt
  
  --movement code (yes i hardcoded the edges)
  self.x = self.x + self.xs
  self.y = self.y + self.ys
  if (self.x < 32) then
    self.x = self.xs-(self.x-32) + 32
    self.xs = -self.xs
  end
  if (self.y < 32) then
    self.y = self.ys-(self.y-32) + 32
    self.ys = -self.ys
  end
  if (self.x > 400-64) then
    self.x = 400-64 - self.xs - ( 400-64 - self.x)
    self.xs = -self.xs
  end
  if (self.y > height - 64) then
    self.y = height-64 - self.ys - ( height-64 - self.y)
    self.ys = -self.ys
  end
end

