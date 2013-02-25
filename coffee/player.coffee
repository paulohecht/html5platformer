class Game.Player extends Game.Object

  velocity: 10
  
  jump: 4.5
  isJumping: false
  maxJumpImpulseTime: 120
  jumpImpulseTime: 0
  
  width: 16
  height: 32
  
  direction: 'right'
  
  footContactCount: 0
  bodyContactCount: 0
  ladderContactCount: 0
  
  onLadder: false
  
  colliderRadius: 10
  
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
          ladder: [15, 16, "ladder", 4]
    
    @tilesetSheet = new createjs.SpriteSheet(imageData)
    @bitmap = new createjs.BitmapAnimation(@tilesetSheet)

    @stage.addChild(@bitmap)
    
    @createPhysicsBody()
    @createBodySensor()
    @createFootSensor()
    
    @respawn(@x, @y)
    
  createPhysicsBody: =>
    @body = new Game.Collider
      shape: 'circle'
      x: @x + @colliderRadius
      y: @y + @colliderRadius
      radius: @colliderRadius
      type: Game.Collider.Type.dynamic
      density: 1.0
      userData: @
    
  createBodySensor: =>
    @body.addCircleFixture
      radius: @colliderRadius / 1.5
      isSensor: true
      userData: "body"
    
  createFootSensor: =>
    @body.addCircleFixture
      radius: @colliderRadius / 4
      offsetY: @colliderRadius
      isSensor: true
      userData: "foot"

  beginContact: (other, fixtureUserData, otherFixtureUserData) =>
    if other instanceof Game.Tile
      if other.isGround()
        if fixtureUserData == "foot" 
          @footContactCount++
        if fixtureUserData == "body"
          @bodyContactCount++
      if other.isLadder()
        if fixtureUserData == "body"
          @ladderContactCount++
    if other instanceof Game.Princess
      @touchPrincess()
    if other instanceof Game.Fish
      @die()
        
  endContact: (other, fixtureUserData, otherFixtureUserData) =>
    if other instanceof Game.Tile
      if other.isGround()
        if fixtureUserData == "foot" 
          @footContactCount--
        if fixtureUserData == "body"
          @bodyContactCount--
      if other.isLadder()
        if fixtureUserData == "body"
          @ladderContactCount--
          
  beforeContact: (other, fixtureUserData, otherFixtureUserData) =>
    #if dead, just let it fall...
    return false if @dead
    #no collision with cloud platforms unless on top of it...
    if other instanceof Game.Tile
      if other.isCloud()
        if @y - other.y > -(@colliderRadius + (other.height / 2) - 0.0)
          return false
    true

  respawn: (@x, @y) =>
    @bitmap.gotoAndPlay("stand_#{@direction}")
    @bitmap.x = @x
    @bitmap.y = @y
    @body.setPosition((@x + @colliderRadius), (@y + @colliderRadius))
    @dead = false
    vel = @body.getVelocity()
    vel.x = 0
    vel.y = 0
    
  fixedUpdate: =>
    if @onLadder
      vel = @body.getVelocity()
      if (Game.Input.isKeyPressed("up"))
        vel.y = -@velocity
      else
        @bitmap.stop()
        #Compensate 1 physics step gravity velocity...
        vel.y = -Game.Physics.GRAVITY.y * Game.Physics.FIXED_TIME_STEP
    
  update: =>
    
    elapsed = Game.Time.deltaTime()
    
    @processInput(elapsed)
    
    @bitmap.x = @x = @body.x - @colliderRadius
    @bitmap.y = @y = @body.y - @colliderRadius * 2
    
    @onLadder = false unless @isTouchingLadder()
    
    @die() if @y > 350
    
  processInput: (elapsed) =>
    return if @dead
    vel = @body.getVelocity()
    vel.x = 0
    vel.x += @velocity if Game.Input.isKeyPressed("right")
    vel.x -= @velocity if Game.Input.isKeyPressed("left")
    if (Game.Input.isKeyPressed("up"))
      if (@isTouchingLadder())
        @onLadder = true
        vel.y = -10
      else
      
        if (@isTouchingGround() && !@isJumping && !(vel.y < 0)) 
          Game.Audio.playSFX("jump-sound") 
          @isJumping = true
          @jumpImpulseTime = 0
  
        if (@isJumping)
          @body.applyImpulse(0, -@jump)
          @jumpImpulseTime += elapsed
  
        if (@jumpImpulseTime > @maxJumpImpulseTime)
          @isJumping = false

    else
      @isJumping = false

    @direction = 'right' if vel.x > 0
    @direction = 'left' if vel.x < 0
    if @onLadder
      @playAnimation("ladder")
    else if @isJumping || Math.abs(vel.y) > 0
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
    vel = @body.getVelocity()
    vel.x = 0
    vel.y = 0
    @body.applyImpulse(0, -(4 * @jump))
    setTimeout((=> @trigger("die")), 1000)
    
  touchPrincess: =>
    @trigger "findprincess"
      
  playAnimation: (animation) =>
    @bitmap.gotoAndPlay(animation) unless animation == @bitmap.currentAnimation

  isTouchingGround: =>
    @footContactCount > 0 && @bodyContactCount == 0

  isTouchingLadder: =>
    @ladderContactCount > 0