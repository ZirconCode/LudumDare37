lume = require "lume"



function love.load()
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
 
  prevX = 0
  prevY = 0
  started = false

  objects = {} -- table to hold all our physical objects
 
  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  objects.ground.shape = love.physics.newRectangleShape(650, 50) --make a rectangle with a width of 650 and a height of 50
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape); --attach shape to body

  -- TODO create walls on all four sides, topdown? nogravity but rest.?
  -- TODO how to determine collision/touching?

  --let's create a ball
  objects.ball = {}
  objects.ball.body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  objects.ball.shape = love.physics.newCircleShape(20) --the ball's shape has a radius of 20
  objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 3) -- Attach fixture to body and give it a density of 1.
  --objects.ball.fixture:setRestitution(0.9) --let the ball bounce
  objects.ball.fixture:setRestitution(0.3)
 
  --let's create a couple blocks to play around with
  objects.block1 = {}
  objects.block1.body = love.physics.newBody(world, 200, 550, "dynamic")
  objects.block1.shape = love.physics.newRectangleShape(0, 0, 50, 100)
  objects.block1.fixture = love.physics.newFixture(objects.block1.body, objects.block1.shape, 5) -- A higher density gives it more mass.
  objects.block1.r = 255
  objects.block1.g = 0
  objects.block1.b = 50
  objects.block1.isBlock = true

  objects.block2 = {}
  objects.block2.body = love.physics.newBody(world, 400, 300, "dynamic")
  objects.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
  objects.block2.fixture = love.physics.newFixture(objects.block2.body, objects.block2.shape, 2)
  objects.block2.r = 50
  objects.block2.g = 0
  objects.block2.b = 250
  objects.block2.isBlock = true

  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.window.setMode(650, 650) --set the window dimensions to 650 by 650
end
 
 
function love.update(dt)
  world:update(dt) --this puts the world into motion
 
  --here we are going to create some keyboard events
  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then --press the right arrow key to push the ball to the right
    objects.ball.body:applyForce(400, 0)
  elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then --press the left arrow key to push the ball to the left
    objects.ball.body:applyForce(-400, 0)
  elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then --press the up arrow key to set the ball in the air
    --objects.ball.body:setPosition(650/2, 650/2)
    --objects.ball.body:setLinearVelocity(0, 0) --we must set the velocity to zero to prevent a potentially large velocity generated by the change in position
    objects.ball.body:setLinearVelocity(0,-400) -- TODO only if touch ground?
  elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
    objects.ball.body:applyForce(0,400)
  end

  if love.keyboard.isDown("g") then
    prevX = love.mouse:getX()
    prevY = love.mouse:getY()
  end

end
 
function love.mousereleased( x, y, button )
  -- create block set with starting point at g
  tmpBlock = {}
  tmpBlock.body = love.physics.newBody(world, math.min(x,prevX)+(math.abs(x-prevX)/2), math.min(y,prevY)+(math.abs(y-prevY)/2), "dynamic")
  tmpBlock.shape = love.physics.newRectangleShape(0, 0, math.abs(x-prevX), math.abs(y-prevY))
  tmpBlock.fixture = love.physics.newFixture(tmpBlock.body, tmpBlock.shape, 5)
  tmpBlock.r = 255
  tmpBlock.g = 0
  tmpBlock.b = 5
  tmpBlock.isBlock = true
  objects.insert(tmpBloc,1)
end

function love.draw()
  love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates


  x = objects.ball.body:getX()
  y = objects.ball.body:getY()
  dist = lume.distance(x,y,0,0,1)
  if (dist < 500000) then
      love.graphics.setColor(0,255,0)
    elseif true then
      love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  end
  love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
 
  for i=1,objects.getn() do
    tmpObj = objects[i]
    if tmpObj.isBlock then
      love.graphics.setColor(tmpObj.r, tmpObj.g, tmpObj.b)
      love.graphics.polygon("fill", tmpObj.body:getWorldPoints(tmpObj.shape:getPoints()))
    end
  end
  --love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  --love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  --love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
end