class Game.Layer extends createjs.Container
  
  render: (@stage) =>
    @stage.addChild(@)
  
  setAsParallax: (@width) =>
    
  setMapWidth: (@mapWidth) =>
    
  update: =>
    if (@width && @mapWidth)
      camera = Game.Instances.getCamera()
      
      @x = -@stage.x - (-@stage.x * ((@width - camera.width) / (@mapWidth - camera.width)))
      
