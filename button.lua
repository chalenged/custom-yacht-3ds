Button = Object.extend(Object)
--Creates a button on the touch screen
function Button.new(self, x,y,w,h,c,image,rotate)
  --position, width, height
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  --a function the button will call when clicked
  self.c = c
  self.clicked = false
  --if no image is provided a simple box is drawn
  self.image = image or nil
  --rotates the image in 90 degree amounts, and uses radians
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