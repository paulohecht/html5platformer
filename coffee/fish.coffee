class Game.Fish

  velocity: 10
  
  width: 32
  height: 32
  
  direction: 'right'
  
  render: (@stage, @x, @y) =>
    imageData =
      images: [Game.Preloader.get("fish-sprite")]
      frames:
        width: 32
        height: 32
      animations:
        default: [0, 1, "default", 4]

    @tilesetSheet = new createjs.SpriteSheet(imageData)
    @bitmap = new createjs.BitmapAnimation(@tilesetSheet)
    @bitmap.gotoAndPlay('default')
    @bitmap.x = @x
    @bitmap.y = @y
    @stage.addChild(@bitmap)
    @offset = (384 - @y)/ @height #Magick number alert... its the bottom most tile height
    @createPhysicsBody()
    createjs.Ticker.addListener(@)
    
  createPhysicsBody: =>
    size = 10
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2CircleShape(size / Game.Physics.SCALE)
    fixDef.density = 1.0
    fixDef.friction = 0.0
    fixDef.restitution = 0
    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.fixedRotation = true
    bodyDef.gravityScale = 10.0
    bodyDef.allowSleep = false
    bodyDef.type = Box2D.Dynamics.b2Body.b2_kinematicBody
    bodyDef.position.Set((@x + size * 1.5) / Game.Physics.SCALE, (@y + size * 1.5) / Game.Physics.SCALE)
    bodyDef.userData = "enemy"
    @body = Game.Physics.createBody(bodyDef)
    @body.CreateFixture(fixDef)
    
    initialY = (400 + @height / 2)
    @y = initialY
    setTimeout( =>
      createjs.Tween.get(@, {loop:true})
        .wait(1000)
        .to({y: 220}, 1000, createjs.Ease.sineOut)
        .to({y: initialY}, 1000, createjs.Ease.sineIn)
    , 1000 * @offset)
    
  tick: (elapsed) =>
    bodyPosition = @body.GetPosition()
    @body.SetPosition({x: bodyPosition.x, y: (@y + @height / 2) / Game.Physics.SCALE})    
    @bitmap.y = @y