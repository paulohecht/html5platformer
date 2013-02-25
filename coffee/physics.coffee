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
    thickness = 32
    new Game.Collider
      shape: 'box'
      x: minX - thickness
      y: 0
      width: thickness
      height: height
    new Game.Collider
      shape: 'box'
      x: maxX + thickness
      y: 0
      width: thickness
      height: height
    
class CustomContactListener extends Box2D.Dynamics.b2ContactListener
    
    sendCallback: (contact, methodName) =>
        fixtureA = contact.GetFixtureA()
        fixtureB = contact.GetFixtureB()
        fixtures = [fixtureA, fixtureB]
        userDataA = fixtureA.GetBody().GetUserData()
        userDataB = fixtureB.GetBody().GetUserData()
        userDatas = [userDataA, userDataB]
        result = true
        for me in [0..1]
          if (_.isObject(userDatas[me]))
            other = (me + 1) % 2 
            userData = userDatas[me]
            fixtureUserData = fixtures[me].GetUserData()
            otherUserData = userDatas[other]
            otherFixtureUserData = fixtures[other].GetUserData()
            if userData.__proto__[methodName]
              result &= userData[methodName](otherUserData, fixtureUserData, otherFixtureUserData) 
        result
        
    BeginContact: (contact) =>
        @sendCallback(contact, "beginContact")
        
    EndContact: (contact) =>
        @sendCallback(contact, "endContact")
    
    PreSolve: (contact, oldManifold) =>
        contact.SetEnabled(@sendCallback(contact, "beforeContact"))