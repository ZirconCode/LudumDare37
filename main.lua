lume = require "lume"
--serialize = require 'ser'
--require "Tserial"
serialize = require 'ser'


function construct()
  -- Construct Objects From Blocks
  i = 1
  for key,value in pairs(blocks) do 
    print(key,value)
    if value.isBlock == true then
        constructBlock(value,i)
        i = i+1
    end
  end
  ---------------------------------
end

function constructBlock(block,name)
  objects[name] = {}
  objects[name].body = love.physics.newBody(world, block.x, block.y) --, "dynamic")
  objects[name].shape = love.physics.newRectangleShape(0, 0, block.w, block.h)
  objects[name].fixture = love.physics.newFixture(objects[name].body, objects[name].shape, 5) -- A higher density gives it more mass.
  objects[name].isBlock = true
  objects[name].r = block.r
  objects[name].g = block.g
  objects[name].b = block.b
end

function clear()
  -- clear all isBlocks from World
  blocks = {}
  -- remove all blocks from objects!!
  -- remove all from physics world
  i = 1
  for key,value in pairs(objects) do 
    print(key,value)
    if value.isBlock == true then
        -- remove from world
        value.body:destroy()
        -- remove from objects
        objects[key] = nil
        i = i+1
    end
  end
end

function love.load()
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
  world:setCallbacks(beginContact, endContact, preSolve, postSolve) -- collision callbacks

  music = love.audio.newSource("testsound.mp3")
  music:play() -- change whatever... no plan TODO
  music:setPitch(0.4)

  prevX = 0
  prevY = 0
  started = false
  canJump = true
  footCount = 0;

  cameraY = 0;

  picSmiley = love.graphics.newImage("smiley.png")
  rotation = 0;

  objects = {} -- table to hold all our physical objects
  blocks = {} -- table for static blocks to load/save ONLY SKELETON DATA
  -- x,y,w,h,r,g,b
 
  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  objects.ground.shape = love.physics.newRectangleShape(650, 50) --make a rectangle with a width of 650 and a height of 50
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape); --attach shape to body

  -- TODO create walls on all four sides, topdown? nogravity but rest.?
  -- TODO how to determine collision/touching?

  --let's create a ball
  objects.ball = {}
  objects.ball.isPlayer = true
  --objects.ball.setUserData 
  objects.ball.body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  objects.ball.shape = love.physics.newCircleShape(20) --the ball's shape has a radius of 20
  objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 3) -- Attach fixture to body and give it a density of 1.
  objects.ball.fixture:setFriction(0.7) -- TODO 
  objects.ball.body:setFixedRotation( true ) 

  -- TODO understand this properly...
  objects.ball.footShape = love.physics.newRectangleShape( 0, 33, 20,2, 0 )
  objects.ball.footFixture = love.physics.newFixture(objects.ball.body,objects.ball.footShape,1)
  objects.ball.footFixture:setUserData("foot")
  objects.ball.footFixture:setSensor(true)
  --objects.ball.footFixture:setFixedRotation( true ) 
  --objects.ball.fixture:setRestitution(0.9) --let the ball bounce
  objects.ball.fixture:setRestitution(0) -- 0.3
 
  --let's create a couple blocks to play around with

  -- structure of block

  -- for now, always FIXED
  blocks.block1 = {}
  blocks.block1.x = 200
  blocks.block1.y = 550
  blocks.block1.w = 50
  blocks.block1.h = 100
  blocks.block1.r = 255
  blocks.block1.g = 0
  blocks.block1.b = 50
  blocks.block1.isBlock = true

  blocks.block2 = {}
  blocks.block2.x = 400
  blocks.block2.y = 300
  blocks.block2.w = 100
  blocks.block2.h = 50
  blocks.block2.r = 50
  blocks.block2.g = 0
  blocks.block2.b = 250
  blocks.block2.isBlock = true

  construct()

  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.window.setMode(650, 650) --set the window dimensions to 650 by 650
end
 
function love.update(dt)
  world:update(dt) --this puts the world into motion
 
  rotation = rotation + dt*100

  -- Adapt Camera?
  -- TODO some clever lume cameraY
  cameraY = lume.lerp(cameraY,-objects.ball.body:getY()+love.graphics.getHeight()-200,1) -- TODO
  -- good enough

  --xVel, yVel = objects.ball.body:getLinearVelocity()
  --music:setPitch(lume.clamp(lume.round((xVel/100),0.1)),0,1)

  --here we are going to create some keyboard events
  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then --press the right arrow key to push the ball to the right
    objects.ball.body:applyForce(400, 0)
  end
  if love.keyboard.isDown("left") or love.keyboard.isDown("a") then --press the left arrow key to push the ball to the left
    objects.ball.body:applyForce(-400, 0)
  end
  if love.keyboard.isDown("up") or love.keyboard.isDown("w") then --press the up arrow key to set the ball in the air
    --objects.ball.body:setPosition(650/2, 650/2)
    --objects.ball.body:setLinearVelocity(0, 0) --we must set the velocity to zero to prevent a potentially large velocity generated by the change in position
    if footCount > 0 then
      objects.ball.body:setLinearVelocity(0,-400) -- TODO only if touch ground?
      -- jump timeout TODO ?
    end
  end

  if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
    objects.ball.body:applyForce(0,400)
  end

  if love.keyboard.isDown("g") then
    prevX = love.mouse:getX()
    prevY = love.mouse:getY()-cameraY
  end

  if love.keyboard.isDown("p") then
    clear()
  end

  -- load/save BLOCKS
  if love.keyboard.isDown("o") then
    str = serialize(blocks)
    print(str)
    love.filesystem.write("level.txt", str)
  end
  if love.keyboard.isDown("l") then
    clear()
    blocks = love.filesystem.load("level.txt")() --str =
    print(blocks)
    --blocks = Tserial.unpack(str, true)
    construct() -- DONT LOAD REPEATEDLY, CLEAR FIRST -> GOOD THINK IT WORKS?
  end

end
 
function love.mousereleased( x, y, button )
  -- create block set with starting point at g
  tmpBlock = {}
  tmpBlock.x = math.min(x,prevX)+(math.abs(x-prevX)/2)
  tmpBlock.y = math.min(-cameraY+y,prevY)+(math.abs(-cameraY+y-prevY)/2)
  tmpBlock.w = math.abs(x-prevX)
  tmpBlock.h = math.abs(-cameraY+y-prevY)
  tmpBlock.r = 255
  tmpBlock.g = 0
  tmpBlock.b = 5
  tmpBlock.isBlock = true
  id = os.time()  -- oh dear TODO... its in sec.
  print(id)
  blocks[id] = tmpBlock
  constructBlock(tmpBlock, id)
end

function love.draw()

  -- CAMERA?
  love.graphics.translate( 0, cameraY ) -- TODO

  love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates


  x = objects.ball.body:getX()
  y = objects.ball.body:getY()
  dist = lume.distance(x,y,0,0,1)
  --if (dist < 500000) then
      love.graphics.setColor(0,255,0)
    --elseif true then
      --love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  --end
  --love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
  --love.graphics.draw(picSmiley, objects.ball.body:getX(), objects.ball.body:getY())
  love.graphics.draw(picSmiley, objects.ball.body:getX(), objects.ball.body:getY(), math.rad(rotation), 1, 1, 40 / 2, 40 / 2)
 
  
  --love.graphics.setColor(50, 50, 50)
  --love.graphics.polygon("fill", objects.ball.footFixture.body:getWorldPoints(objects.ball.footFixture.shape:getPoints()))

  for key,value in pairs(objects) do 
    --print(key,value)
    if value.isBlock == true then
      love.graphics.setColor(value.r, value.g, value.b)
      love.graphics.polygon("fill", value.body:getWorldPoints(value.shape:getPoints()))
    end
  end
  --love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  --love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  --love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
end

function beginContact(a, b, coll)
  -- analyze if can jump again TODO
  if a:getUserData() == "foot" or b:getUserData() == "foot" then
    print("begin")
    footCount = footCount+1
  end
end
 
function endContact(a, b, coll)
 if a:getUserData() == "foot" or b:getUserData() == "foot" then
    print("end")
    footCount = footCount-1
  end
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end
