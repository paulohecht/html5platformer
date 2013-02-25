class Game.Princess extends Game.Object
  
  width: 32
  height: 32
  
  
  render: (@stage, @x, @y) =>
    
    imageData =
      images: [Game.Preloader.get("tileset")]
      frames:
        width: @width
        height: @height
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
    physicsSize = 10
    @body = new Game.Collider
      shape: "circle"
      x: @x + physicsSize * 1.5 
      y: @y + physicsSize * 2 
      radius: physicsSize
      type: Game.Collider.Type.kinematic
      isSensor: true
      userData: @