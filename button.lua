Button = Object.extend(Object)

function Button.new(self, x,y,w,h,c,image,rotate)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.c = c
  self.clicked = false
  self.image = image or nil
  self.rotate = rotate or 0
end

function Button.click(self)
  if (not self.clicked) then
    self.c()
    self.clicked = true
  end
end

function Button.draw(self)
  if (self.image==nil) then 
      love.graphics.setColor(0.7,0,0,1)
      love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
      return
  end
  dx, dy = self.x, self.y
  if self.rotate == 0.5*math.pi then
    dx = dx + self.w
  elseif self.rotate == math.pi then
    dx = dx + self.w
    dy = dy + self.h
  elseif self.rotate == 1.5*math.pi then
    dy = dy + self.h
  end
      love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.image,dx,dy,self.rotate,1,1,0,0)
end