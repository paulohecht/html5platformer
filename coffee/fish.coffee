class Game.Fish extends Game.Object

  width: 32
  height: 32
  
  render: (@stage, @x, @y) =>
    imageData =
      images: [Game.Preloader.get("fish-sprite")]
      frames:
        width: @width
        height: @height
      animations:
        default: [0, 1, "default", 4]

    @tilesetSheet = new createjs.SpriteSheet(imageData)
    @bitmap = new createjs.BitmapAnimation(@tilesetSheet)
    @bitmap.gotoAndPlay('default')
    @bitmap.x = @x
    @bitmap.y = @y
    @stage.addChild(@bitmap)
    @createPhysicsBody()
    @setTween()
    
  createPhysicsBody: =>
    physicsSize = 10
    @body = new Game.Collider
      shape: "circle"
      x: @x + physicsSize * 1.5
      y: @y + physicsSize * 1.5
      radius: physicsSize
      type: Game.Collider.Type.kinematic
      userData: @

  setTween: =>
    offset = (400 - @y)/ @height #Magick number alert... its the bottom most tile height
    initialY = (400 + @height / 2)
    @y = initialY
    setTimeout( =>
      createjs.Tween.get(@, {loop:true})
        .wait(1000)
        .to({y: 220}, 1000, createjs.Ease.sineOut)
        .to({y: initialY}, 1000, createjs.Ease.sineIn)
    , 1000 * offset)

  update: =>
    physicsSize = 10
    @body.setPosition((@x + physicsSize * 1.5), (@y + physicsSize * 1.5))
    @bitmap.y = @y