class Game.Time
  
  _instance = undefined
  
  @instance: =>
    _instance ?= new Game.TimeImpl()
    
  @update: (elapsed) =>
    @instance().update(elapsed)
    
  @on: (args...) =>
    @instance().on(args...)
    
  @time: =>
    @instance().time
    
  @deltaTime: =>
    @instance().deltaTime
  
class Game.TimeImpl extends Game.Mixable
  
  mixins: [Game.Events]
  
  time: 0
  deltaTime: 0
  
  update: (elapsed) =>
    @time += elapsed
    @deltaTime = elapsed
    @trigger("update")
    @trigger("lateupdate")
