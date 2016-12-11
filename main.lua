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
    elseif value.isTele == true then
      constructTele(value,i)
    elseif value.isTeleBlock == true then
      constructTeleBlock(value,i)
    end
    i = i+1
  end
  ---------------------------------
end

function constructBlock(block,name)
  objects[name] = {}
  objects[name].body = love.physics.newBody(world, block.x, block.y) --, "dynamic")
  objects[name].shape = love.physics.newRectangleShape(0, 0, block.w, block.h)
  objects[name].fixture = love.physics.newFixture(objects[name].body, objects[name].shape, 5) -- A higher density gives it more mass.
  objects[name].isBlock = true
  objects[name].r = 50 --block.r --TODO
  objects[name].g = 50 --block.g
  objects[name].b = 50 --block.b
  objects[name].body:setUserData(name)
end

function constructTeleBlock(block,name)
  objects[name] = {}
  objects[name].body = love.physics.newBody(world, block.x, block.y) --, "dynamic")
  objects[name].shape = love.physics.newRectangleShape(0, 0, block.w, block.h)
  objects[name].fixture = love.physics.newFixture(objects[name].body, objects[name].shape, 5) -- A higher density gives it more mass.
  objects[name].isTeleBlock = true
  objects[name].switchNum = block.switchNum
  objects[name].fixture:setUserData("tb" .. tostring(block.switchNum))
  objects[name].r = teleColors[block.switchNum].r --block.r
  objects[name].g = teleColors[block.switchNum].g --block.g
  objects[name].b = teleColors[block.switchNum].b --block.b
  objects[name].body:setUserData(name)
end

function constructTele(block,name)
  objects[name] = {}
  objects[name].body = love.physics.newBody(world, block.x, block.y) --, "dynamic")
  objects[name].shape = love.physics.newRectangleShape(0, 0, block.w, block.h)
  objects[name].fixture = love.physics.newFixture(objects[name].body, objects[name].shape, 5) -- A higher density gives it more mass.
  objects[name].isTele = true
  objects[name].switchNum = block.switchNum
  objects[name].vanish = teleVanish -- TODO!!
  objects[name].fixture:setUserData("t" .. tostring(block.switchNum))
  objects[name].fixture:setSensor(true)
  objects[name].r = teleColors[block.switchNum].r --block.r
  objects[name].g = teleColors[block.switchNum].g --block.g
  objects[name].b = teleColors[block.switchNum].b --block.b
  objects[name].body:setUserData(name)
end

function updateTeleBlockMasks()
  -- TODO
  for key,value in pairs(objects) do 
    if value.isTeleBlock == true then
      if(switchStates[value.switchNum] == true) then
        value.fixture:setMask(2) -- MASK 2 = CANT TOUCH THIS
      elseif true then
        value.fixture:setMask(1)
      end
      --print(value.fixture:getMask())
    end
  end
end

function deleteObjectsAt(x,y)
  for key,value in pairs(objects) do 
    print(x)
    print(y)
    shape = value.shape
    tx, ty = value.body:getPosition()
    isInside = shape:testPoint(tx,ty,0,x,y)
    if isInside and (value.isTele or value.isBlock or value.isTeleBlock) then
      -- remove from world
        -- remove from objects
        -- remove from BLOCKS? HOW? ------------___TODODOOODDO
        id = objects[key].body:getUserData()
                value.body:destroy()

        objects[key] = nil
        blocks[id] = nil
        print("INSIDE")
    end
  end
end

function vanishTeleporters(num)
  blocks = {}
  for key,value in pairs(objects) do 
    print(key,value)
    if ((value.isTele == true) and (value.switchNum == num)) then
        -- remove from world
        value.body:destroy()
        -- remove from objects
        objects[key] = nil
    end
  end
end

function clear()
  -- clear all isBlocks from World
  blocks = {}
  -- remove all blocks from objects!!
  -- remove all from physics world
  for key,value in pairs(objects) do 
    print(key,value)
    if ((value.isBlock == true) or (value.isTele == true) or (value.isTeleBlock == true)) then
        -- remove from world
        value.body:destroy()
        -- remove from objects
        objects[key] = nil
    end
  end
end

function love.load()
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
  world:setCallbacks(beginContact, endContact, preSolve, postSolve) -- collision callbacks

  musicPiece1 = love.audio.newSource("LudumDare37Kitschig1.ogg")
  musicPiece2 = love.audio.newSource("LudumDare37Kitschig2Loop.ogg")
  musicPiece1:setLooping(false)
  musicPiece2:setLooping(true)
  --musicPiece1:setPitch(0.4)
  musicPiece1:play() -- change whatever... no plan TODO

  prevX = 0
  prevY = 0
  started = false
  canJump = true
  footCount = 0

  teleTimeout = 0
  teleCurrent = 1
  teleX = -1
  teleY = -1

  delX = -1
  delY = -1

  teleVanish = false --should current teleporter pair vanish when used?

  -- teleporter colors
  teleColors = {}
  teleColors[1] = {}
  teleColors[1].r = 255
  teleColors[1].g = 0
  teleColors[1].b = 0
  teleColors[2] = {}
  teleColors[2].r = 0
  teleColors[2].g = 255
  teleColors[2].b = 0
  teleColors[3] = {}
  teleColors[3].r = 0
  teleColors[3].g = 0
  teleColors[3].b = 255

  cameraY = 0

  picSmiley = love.graphics.newImage("smiley.png")
  rotation = 0

  editSwitch = 1
  switchStates = {}
  for i = 1,9 do
    switchStates[i] = false
    --love.keyboard.setKeyRepeat( enable )
  end
  switchStates[3] = true

  objects = {} -- table to hold all our physical objects
  blocks = {} -- table for static blocks to load/save ONLY SKELETON DATA
  -- x,y,w,h,r,g,b
 
  --let's create the ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  objects.ground.shape = love.physics.newRectangleShape(200, 50) --make a rectangle with a width of 650 and a height of 50
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

  -- for now, always FIXE
  --[[
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
  --]]

  -- LOAD FROM theroomlevel.txt
  -- blocks = require 'level' --TODO THIS WORKS NICE
  construct()
  updateTeleBlockMasks()

  --initial graphics setup
  love.graphics.setBackgroundColor(20, 5, 0) --set the background color to a nice blue
  love.window.setMode(650, 650) --set the window dimensions to 650 by 650
end
 
function love.update(dt)
  -- teleport?
  if(delX ~= -1 and delY ~= -1) then
        deleteObjectsAt(delX,delY)
        delX = -1
        delY = -1 -- haha oh dear TODO
  end

  if(teleTimeout == 0 and teleX > 0 and teleY > 0) then
    objects.ball.body:setPosition(teleX, teleY-50)
    objects.ball.body:setLinearVelocity(0, -50)
    teleX = -1
    teleY = -1
    teleTimeout = 2.0
    switchStates[teleCurrent] = not switchStates[teleCurrent]--toogle
    print(tostring(switchStates[teleCurrent]))
    print(tostring(teleCurrent))
    updateTeleBlockMasks()

    -- CHECK IF VANISH
    if teleCurrent == 3 then -- TODO
      vanishTeleporters(teleCurrent)
    end
  end
  teleTimeout = lume.clamp(teleTimeout-dt,0,10)
  --print(tostring(teleTimeout))

  if(musicPiece1:isStopped()) then
    musicPiece2:play()
  end

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

  for i=1,9 do
    if love.keyboard.isDown(tostring(i)) then
      print(tostring(i))
      editSwitch = i
    end
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
    updateTeleBlockMasks()
  end

end

function love.keyreleased(key)
  if key == "r" then
    delX = love.mouse:getX()
    delY = love.mouse:getY()-cameraY
  end
  if key == "t" then -- TODO still repeats?
    -- place teleporter
    tmpBlock = {}
    tmpBlock.x = love.mouse:getX()
    tmpBlock.y = love.mouse:getY()-cameraY
    tmpBlock.w = 50
    tmpBlock.h = 20
    tmpBlock.r = 255
    tmpBlock.g = 0
    tmpBlock.b = 255
    tmpBlock.isTele = true
    tmpBlock.switchNum = editSwitch
    id = os.time()  -- oh dear TODO... its in sec.
    print(id)
    blocks[id] = tmpBlock
    constructTele(tmpBlock, id)
  end
  if key == "y" then
    -- construct teleblock
    tmpBlock = {}
    tmpBlock.x = math.min(love.mouse:getX(),prevX)+(math.abs(love.mouse:getX()-prevX)/2)
    tmpBlock.y = math.min(-cameraY+love.mouse:getY(),prevY)+(math.abs(-cameraY+love.mouse:getY()-prevY)/2)
    tmpBlock.w = math.abs(love.mouse:getX()-prevX)
    tmpBlock.h = math.abs(-cameraY+love.mouse:getY()-prevY)
    tmpBlock.r = 255
    tmpBlock.g = 0
    tmpBlock.b = 255
    tmpBlock.isTeleBlock = true
    tmpBlock.switchNum = editSwitch
    id = os.time()  -- oh dear TODO... its in sec.
    print(id)
    blocks[id] = tmpBlock
    constructTeleBlock(tmpBlock, id)
  end
  if key == "0" then
    teleVanish = not teleVanish
    print("TELEVANISH:")
    print(teleVanish)
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
    if value.isTele == true then
      love.graphics.setColor(value.r, value.g, value.b)
      love.graphics.polygon("fill", value.body:getWorldPoints(value.shape:getPoints()))
    end
    if value.isTeleBlock == true then
      num = value.switchNum
      if(switchStates[num] == true) then
        love.graphics.setColor(value.r, value.g, value.b)
        love.graphics.polygon("fill", value.body:getWorldPoints(value.shape:getPoints()))
      elseif true then
        love.graphics.setColor(value.r, value.g, value.b)
        love.graphics.polygon("line", value.body:getWorldPoints(value.shape:getPoints()))
      end
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

  -- teleporters
  for i=1,9 do
    str = "t" .. tostring(i)
    if a:getUserData() == str or b:getUserData() == str then
      -- current teleporter
      if a:getUserData() == str then
        collFixt = a
      elseif true then
        collFixt = b
      end

      -- find pair tele
      for key,value in pairs(objects) do 
        if ( ((value.isTele == true) and (value.switchNum == i)) and (value.fixture ~= collFixt) ) then
          -- teleport to that other teleporter
          teleX,teleY = value.body:getWorldPoints(value.body:getLocalCenter())
          teleCurrent = i
        end
      end

      print(str)
    end
  end
  

end
 
function endContact(a, b, coll)
 if a:getUserData() == "foot" or b:getUserData() == "foot" then
    print("end")
    footCount = footCount-1
  end

  for i=1,9 do
    str = "t" .. tostring(i)
    if a:getUserData() == str or b:getUserData() == str then
      teleX = -1
      teleY = -1
    end
  end
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end

