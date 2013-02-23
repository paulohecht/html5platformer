class Game.Camera
  
  x: 0
  
  y: 0
  
  width: 0
  
  height: 0
  
  target: null
  
  targetOffsetX: 0
  
  targetOffsetY: 0
  
  minX: 0
  
  maxX: null
  
  constructor: (@stage) ->
    @width = @stage.canvas.width
    @height = @stage.canvas.height
  
  update: =>
    @x = @target.x + @targetOffsetX - (@width / 2) if @target
    
    @x = Math.max(@x, @minX)
    @x = Math.min(@x, @maxX - @width)

  setTarget: (@target) =>
    
  setBounds: (@minX, @maxX) =>
