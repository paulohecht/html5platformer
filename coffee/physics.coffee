class Game.Physics
  
  @SCALE: 20.0
  @GRAVITY: {x: 0, y: 50}
  @FIXED_TIME_STEP: 1 / 60
  
  _instance = undefined
  
  @instance: =>
    _instance ?= new Game.PhysicsImpl()
    
  @init: =>
    @instance().init()
    
  @update: (elapsed) =>
    @instance().update(elapsed)
  
  @createBody: (body) =>
    @instance().createBody(body)
    
  @createWorldLateralbounds: (minX, maxX, height) =>
    @instance().createWorldLateralbounds(minX, maxX, height)
    
  @on: (args...) =>
    @instance().on(args...)  
    
class Game.PhysicsImpl extends Game.Mixable
  
  mixins: [Game.Events]
  
  proccessTime: 0
  
  showDebug: false
  
  init: =>
    @world = new Box2D.Dynamics.b2World(Game.Physics.GRAVITY, true)
    @world.SetContactListener(new CustomContactListener())
    
    @debugDraw = new Box2D.Dynamics.b2DebugDraw()
    @debugDraw.SetSprite(document.getElementById("debugCanvas").getContext("2d"))
    @debugDraw.SetDrawScale(Game.Physics.SCALE)
    @debugDraw.SetFillAlpha(0.2)
    @debugDraw.SetLineThickness(1.0)
    @debugDraw.SetFlags(Box2D.Dynamics.b2DebugDraw.e_shapeBit)
    @world.SetDebugDraw(@debugDraw)
    
  update: (elapsed) =>
    
    @showDebug = !@showDebug if Game.Input.isKeyDown("d")
    
    @proccessTime += elapsed
    fixedTickMs = Game.Physics.FIXED_TIME_STEP * 1000
    while(@proccessTime > fixedTickMs)
      @trigger "update"
      @world.Step(Game.Physics.FIXED_TIME_STEP, 10, 10)
      @world.ClearForces()
      @proccessTime -= fixedTickMs
      
    if @showDebug
      @world.DrawDebugData()
      $("#debugCanvas").show()
    else
      $("#debugCanvas").hide()

  createBody: (body) =>
    @world.CreateBody(body)

  createWorldLateralbounds: (minX, maxX, height) =>
    scale = Game.Physics.SCALE
    thickness = 32
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(thickness / scale, height / scale)
    leftBodyDef = new Box2D.Dynamics.b2BodyDef()
    leftBodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
    leftBodyDef.position.Set(-thickness / scale, 0 / scale)
    leftBody = Game.Physics.createBody(leftBodyDef)
    leftBody.CreateFixture(fixDef)
    rightBodyDef = new Box2D.Dynamics.b2BodyDef()
    rightBodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
    rightBodyDef.position.Set((maxX + thickness) / scale, 0 / scale)
    rightBody = Game.Physics.createBody(rightBodyDef)
    rightBody.CreateFixture(fixDef)
    
    
class CustomContactListener extends Box2D.Dynamics.b2ContactListener
    
    BeginContact: (contact) =>
        fixtureA = contact.GetFixtureA()
        fixtureB = contact.GetFixtureB()
        userDataA = fixtureA.GetBody().GetUserData()
        userDataB = fixtureB.GetBody().GetUserData()
        
        #Ground sensor...
        sensorName = "foot"
        if ((fixtureA.GetUserData() == sensorName && @isGround(userDataB)) || (fixtureB.GetUserData() == sensorName && @isGround(userDataA)))
          Game.Instances.getPlayer().addFootContact()
        sensorName = "body"
        if ((fixtureA.GetUserData() == sensorName && @isGround(userDataB)) || (fixtureB.GetUserData() == sensorName && @isGround(userDataA)))
          Game.Instances.getPlayer().addBodyContact()
          
        if (userDataA == "player" || userDataB == "player") 
          Game.Instances.getPlayer().onCollisionEnter((if userDataA == "player" then userDataB else userDataA))
        
    EndContact: (contact) =>
        fixtureA = contact.GetFixtureA()
        fixtureB = contact.GetFixtureB()
        userDataA = fixtureA.GetBody().GetUserData()
        userDataB = fixtureB.GetBody().GetUserData()

        #Ground sensor...          
        sensorName = "foot"
        if ((fixtureA.GetUserData() == sensorName && @isGround(userDataB)) || (fixtureB.GetUserData() == sensorName && @isGround(userDataA)))
          Game.Instances.getPlayer().removeFootContact()
        sensorName = "body"
        if ((fixtureA.GetUserData() == sensorName && @isGround(userDataB)) || (fixtureB.GetUserData() == sensorName && @isGround(userDataA)))
          Game.Instances.getPlayer().removeBodyContact()
          
        if (userDataA == "player" || userDataB == "player") 
          Game.Instances.getPlayer().onCollisionExit((if userDataA == "player" then userDataB else userDataA))
    
    PreSolve: (contact, oldManifold) =>
        fixtureA = contact.GetFixtureA()
        fixtureB = contact.GetFixtureB()
        userDataA = fixtureA.GetBody().GetUserData()
        userDataB = fixtureB.GetBody().GetUserData()
        #Player is dead, ignore collisions and let it fall
        if (userDataA == "player" || userDataB == "player")
          if (Game.Instances.getPlayer().isDead())
            contact.SetEnabled(false)    
        #Cloud platform (one-way platforms)
        if @checkReciprocrate(userDataA, userDataB, "player", "cloud")
          playerBody = fixtureA.GetBody()
          cloudBody = fixtureB.GetBody()
          [playerBody, cloudBody] = [cloudBody, playerBody] if userDataA == "cloud"
          playerPosition = playerBody.GetPosition().y
          playerRadius = playerBody.GetFixtureList().GetShape().GetRadius()
          cloudPosition = cloudBody.GetPosition().y
          cloudVertices = cloudBody.GetFixtureList().GetShape().GetVertices()
          cloudHeight = cloudVertices[2].y - cloudVertices[0].y 
          if playerPosition - cloudPosition > -(playerRadius + (cloudHeight / 2) - 0.1) || playerBody.GetLinearVelocity().y < 0
            contact.SetEnabled(false)
      checkReciprocrate: (var1, var2, value1, value2) =>
        (var1 == value1 && var2 == value2) || (var1 == value2 && var2 == value1)
        
      isGround: (value) =>
        value in ["box", "cloud"]
