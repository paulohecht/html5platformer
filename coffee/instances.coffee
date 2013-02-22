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