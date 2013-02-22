class Game.Player extends Game.Mixable
  
  mixins: [Game.Events]

  velocity: 10
  
  jump: 4.5
  isJumping: false
  maxJumpImpulseTime: 100
  jumpImpulseTime: 0
  maxJumpHeight: 5
  jumpInitialY: 0
  
  width: 16
  height: 32
  
  direction: 'right'
  
  physicsSize: 10
  
  render: (@stage, @x, @y) =>
    
    imageData =
      images: [Game.Preloader.get("player-sprite")]
      frames:
        width: 16
        height: 32
      animations:
          run_right: 
            frames: [0, 1, 2, 1]
          stand_right: 1
          jump_right: 12
          run_left: 
            frames: [6, 7, 8, 7]
          stand_left: 7
          jump_left: 13
          death: 14
    
    @tilesetSheet = new createjs.SpriteSheet(imageData)
    @bitmap = new createjs.BitmapAnimation(@tilesetSheet)

    @stage.addChild(@bitmap)
    
    #createjs.Ticker.addListener(@)
    
    @createPhysicsBody()
    
    @respawn(@x, @y)
    
  createPhysicsBody: =>
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2CircleShape(@physicsSize / Game.Physics.SCALE)
    fixDef.density = 1.0
    fixDef.friction = 0.0
    fixDef.restitution = 0
    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.fixedRotation = true
    bodyDef.gravityScale = 10.0
    bodyDef.allowSleep = false
    bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
    bodyDef.position.Set((@x + @physicsSize) / Game.Physics.SCALE, (@y + @physicsSize) / Game.Physics.SCALE)
    bodyDef.userData = "player"
    @body = Game.Physics.createBody(bodyDef)
    @body.CreateFixture(fixDef)
    
  respawn: (@x, @y) =>
    @bitmap.gotoAndPlay("stand_#{@direction}")
    @bitmap.x = @x
    @bitmap.y = @y
    @body.SetPosition({x: (@x + @physicsSize) / Game.Physics.SCALE, y: (@y + @height) / Game.Physics.SCALE})
    @dead = false
    vel = @body.GetLinearVelocity()
    vel.x = 0
    vel.y = 0
    
  update: (elapsed) =>
    
    @processInput(elapsed)
    
    @bitmap.x = @x = (@body.GetPosition().x * Game.Physics.SCALE) - @physicsSize
    @bitmap.y = @y = (@body.GetPosition().y * Game.Physics.SCALE) - 22
    
    @die() if @y > 350

  processInput: (elapsed) =>

    return if @dead
    
    vel = @body.GetLinearVelocity()
    vel.x = 0
    vel.x += @velocity if Game.Input.isKeyPressed("right")
    vel.x -= @velocity if Game.Input.isKeyPressed("left")

    if (Game.Input.isKeyPressed("up") && (vel.y == 0 || @isJumping))
      @body.ApplyImpulse({ x: 0, y: -@jump }, @body.GetWorldCenter())
      unless @isJumping
        @jumpInitialY = @body.GetPosition().y
        Game.Audio.playSFX("jump-sound") 
      if (@jumpImpulseTime > @maxJumpImpulseTime)
        @isJumping = false
      else
        @jumpImpulseTime += elapsed
        @isJumping = true
    else
      @isJumping = false
      @jumpImpulseTime = 0

    if @isJumping && (@jumpInitialY - @body.GetPosition().y > @maxJumpHeight)
      @isJumping = false
      vel.y = 1
    
    @direction = 'right' if vel.x > 0
    @direction = 'left' if vel.x < 0
    
    if @isJumping || Math.abs(vel.y) > 0
      @playAnimation("jump_#{@direction}")
    else
      if Math.abs(vel.x) > 0
        @playAnimation("run_#{@direction}")
      else
        @playAnimation("stand_#{@direction}")

  die: =>
    return if @dead
    @dead = true
    @playAnimation("death")
    Game.Audio.playSFX("dead-sound")
    vel = @body.GetLinearVelocity()
    vel.x = 0
    vel.y = 0
    @body.ApplyImpulse({ x: 0, y: -20 }, @body.GetWorldCenter())
    setTimeout((=> @trigger("die")), 1000)
    
  isDead: =>
    @dead
    
  touchPrincess: =>
    Game.Audio.playSFX("princess-sound") 
    Game.Popup.show("saved")
      
  playAnimation: (animation) =>
    @bitmap.gotoAndPlay(animation) unless animation == @bitmap.currentAnimation
