class Game.Audio
  
  _instance = undefined
  
  @instance: =>
    _instance ?= new Game.AudioImpl()
    
  @playSFX: (id) =>
    @instance().playSFX(id)
    
  @playBG: (id) =>
    @instance().playBG(id)
    
  @pause: =>
    @instance().pause()
    
  @resume: (id) =>
    @instance().resume()
    
  @toggleMuteSFX: =>
    @instance().toggleMuteSFX()
    
  @muteSFX: =>
    @instance().muteSFX()
    
  @unmuteSFX: =>
    @instance().unmuteSFX()

  @toggleMuteBG: =>
    @instance().toggleMuteBG()
    
  @muteBG: =>
    @instance().muteBG()
    
  @unmuteBG: =>
    @instance().unmuteBG()
    
class Game.AudioImpl
  
  isMuteSFX: false
  isMuteBG: false
  
  bgInstance: null
  
  playSFX: (id) =>
      return if @isMuteSFX
      #Play the sound: play (src, interrupt, delay, offset, loop, volume, pan)
      createjs.SoundJS.play(id, createjs.SoundJS.INTERRUPT_ANY)

  playBG: (id) =>
    @bgInstance = createjs.SoundJS.play(id, createjs.SoundJS.INTERRUPT_ANY, 0, 0, -1, 0.4) 

  muteSFX: =>
    @isMuteSFX = true

  unmuteSFX: =>
    @isMuteSFX = false

  toggleMuteSFX: =>
    @isMuteSFX = !@isMuteSFX
    
  muteBG: =>
    @isMuteBG = true
    @updateBGInstance()

  unmuteBG: =>
    @isMuteBG = false
    @updateBGInstance()

  toggleMuteBG: =>
    @isMuteBG = !@isMuteBG
    @updateBGInstance()
    
  updateBGInstance: =>
    return unless @bgInstance
    if @isMuteBG
      @bgInstance.setVolume(0)
    else
      @bgInstance.setVolume(1)
      
  pause: =>
    @bgInstance.setVolume(0)
    
  resume: =>
    @updateBGInstance()
