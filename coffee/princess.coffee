class Game.Princess extends Game.Mixable
  
  width: 32
  height: 32
  
  physicsSize: 10
  
  render: (@stage, @x, @y) =>
    
    imageData =
      images: [Game.Preloader.get("tileset")]
      frames:
        width: 32
        height: 32
      animations:
          default: 24
    
    @tilesetSheet = new createjs.SpriteSheet(imageData)
    @bitmap = new createjs.BitmapAnimation(@tilesetSheet)

    @bitmap.gotoAndStop("default")
    @bitmap.x = @x
    @bitmap.y = @y

    @stage.addChild(@bitmap)
    
    @createPhysicsBody()
    
  createPhysicsBody: =>
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2CircleShape(@physicsSize / Game.Physics.SCALE)
    fixDef.density = 1.0
    fixDef.friction = 0.0
    fixDef.restitution = 0
    fixDef.isSensor = true
    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.fixedRotation = true
    bodyDef.gravityScale = 10.0
    bodyDef.allowSleep = false
    bodyDef.type = Box2D.Dynamics.b2Body.b2_kinematicBody
    bodyDef.position.Set((@x + @physicsSize * 1.5) / Game.Physics.SCALE, (@y + @physicsSize * 2) / Game.Physics.SCALE)
    bodyDef.userData = "princess"
    @body = Game.Physics.createBody(bodyDef)
    @body.CreateFixture(fixDef)