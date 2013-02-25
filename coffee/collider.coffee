class Game.Collider extends Game.Behaviour
  
  @Type:
    dynamic: Box2D.Dynamics.b2Body.b2_dynamicBody
    static: Box2D.Dynamics.b2Body.b2_staticBody
    kinematic: Box2D.Dynamics.b2Body.b2_kinematicBody
    
  body: null
  
  x: 0
  y: 0
    
  initialize: (@options) =>
    @x = options.x || 0
    @y = options.y || 0
    @type = options.type || Game.Collider.Type.static
    @shape = options.shape || 'box'
    @createBody(@options)
    switch @shape
      when 'box' then @addBoxFixture(@options)
      when 'circle' then @addCircleFixture(@options)
    
  createBody: (options = {}) =>
    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.fixedRotation = options.fixedRotation || true
    bodyDef.allowSleep = options.allowSleep || false
    bodyDef.type = @type
    if options.userData
      bodyDef.userData = options.userData
      options.userData = null 
    scale = Game.Physics.SCALE
    bodyDef.position.Set(@x / scale, @y / scale)
    @body = Game.Physics.createBody(bodyDef)
    
  addCircleFixture: (options) =>
    radius = options.radius || 1
    scale = Game.Physics.SCALE
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2CircleShape(radius / scale)
    @createFixture(fixDef, options)
    
  addBoxFixture: (options) =>
    width = options.width || 1
    height = options.height || 1
    scale = Game.Physics.SCALE
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(width / scale, height / scale)
    @createFixture(fixDef, options)
    
  createFixture: (fixDef, options) =>
    fixDef.density = options.density || 0.0
    fixDef.friction = options.friction || 0.0
    fixDef.restitution = options.restitution || 0.0
    fixDef.isSensor = options.isSensor || false
    fixDef.userData = options.userData if options.userData
    scale = Game.Physics.SCALE
    fixDef.shape.m_p.x = options.offsetX / scale if options.offsetX
    fixDef.shape.m_p.y = options.offsetY / scale if options.offsetY 
    @body.CreateFixture(fixDef)

  fixedUpdate: =>
    return unless @body
    position = @body.GetPosition()
    scale = Game.Physics.SCALE
    @x = position.x * scale
    @y = position.y * scale

  
  getVelocity: =>
    @body.GetLinearVelocity()

  setPosition: (@x, @y) =>
    return unless @body
    scale = Game.Physics.SCALE
    @body.SetPosition({x: (@x) / scale, y: (@y) / scale})
    
  applyImpulse: (x, y) =>
    @body.ApplyImpulse({ x: x, y: y }, @body.GetWorldCenter())
