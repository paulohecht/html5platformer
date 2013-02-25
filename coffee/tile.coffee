class Game.Tile extends Game.Object
  
  render: (@stage, @tilesetSheet, @idx, @x, @y, @width, @height, @tileData = {}) =>
    @bitmap = new createjs.BitmapAnimation(@tilesetSheet)
    @bitmap.gotoAndStop(@idx)
    @bitmap.x = @x
    @bitmap.y = @y
    @stage.addChild(@bitmap)
    debugger
    @type = @tileData.collision
    
    switch @type
      when "box" then @createCollisionBox()
      when "cloud" then @createCollisionBox()
      when "ladder" then @createLadderBox()
      
  createCollisionBox: =>
    tileSize = 16
    @body = new Game.Collider
      shape: 'box'
      x: @x + tileSize
      y: @y + tileSize
      width: tileSize
      height: tileSize
      type: Game.Collider.Type.static
      userData: @

  createLadderBox: =>
    tileSize = 16
    size = 8
    @body = new Game.Collider
      shape: 'box'
      x: @x + tileSize
      y: @y + tileSize
      width: size
      height: size
      type: Game.Collider.Type.static
      isSensor: true
      userData: @
      
  isGround: =>
    @type in ['box', 'cloud']

  isCloud: =>
    @type in ['cloud']

  isLadder: =>
    @type in ['ladder']
