class Game.Tile
  
  render: (@stage, @tilesetSheet, @idx, @x, @y, @tileData = {}) =>
    
    #@idx = 135 if 'collision' of @tileData
    
    @bitmap = new createjs.BitmapAnimation(@tilesetSheet)
    @bitmap.gotoAndStop(@idx)
    @bitmap.x = @x
    @bitmap.y = @y
    @stage.addChild(@bitmap)
    
    switch @tileData.collision
      when "box" then @createCollisionBox()
      when "cloud" then @createCollisionBox()
      when "ladder" then @createLadderBox()
      
  createCollisionBox: =>
    size = 16
    scale = Game.Physics.SCALE
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(size / scale, size / scale)
    fixDef.density = 0.0
    fixDef.friction = 0.0
    fixDef.restitution = 0
    fixDef.isSensor = true if @tileData.collision in ["ladder"]
    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
    bodyDef.position.Set((@x + size) / scale, (@y + size) / scale)
    bodyDef.userData = @tileData.collision
    @body = Game.Physics.createBody(bodyDef)
    @body.CreateFixture(fixDef)    
      
  createLadderBox: =>
    size = 8
    tileSize = 16
    scale = Game.Physics.SCALE
    fixDef = new Box2D.Dynamics.b2FixtureDef()
    fixDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
    fixDef.shape.SetAsBox(size / scale, size / scale)
    fixDef.isSensor = true if @tileData.collision in ["ladder"]
    bodyDef = new Box2D.Dynamics.b2BodyDef()
    bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
    bodyDef.position.Set((@x + tileSize) / scale, (@y + tileSize) / scale)
    bodyDef.userData = @tileData.collision
    @body = Game.Physics.createBody(bodyDef)
    @body.CreateFixture(fixDef)    