class Game.Instances
  
  _instance = undefined
  
  @instance: =>
    _instance ?= new Game.InstancesImpl()
    
  @createStage: (id) =>
    @instance().createStage(id)
    
  @getStage: =>
    @instance().getStage()

  @createPlayer: =>
    @instance().createPlayer()
  
  @getPlayer: =>
    @instance().getPlayer()

  @createCamera: (stage) =>
    @instance().createCamera(stage)
  
  @getCamera: =>
    @instance().getCamera()
  
class Game.InstancesImpl
  
  createPlayer: =>
    @player = new Game.Player()
    @player
    
  getPlayer: =>
    @player
    
  createStage: (id) =>
    @stage = new createjs.Stage(id)
    @stage
    
  getStage: =>
    @stage 

  createCamera: (stage) =>
    @camera = new Game.Camera(stage)
    @camera
    
  getCamera: =>
    @camera