class Game.Preloader
  
  preloader = undefined
  
  @load: (url, callback) =>
    preloader ?= new Game.PreloaderImpl()
    preloader.load(url, callback)
    
  @get: (id) =>
    preloader.get(id) if (preloader)
  
class Game.PreloaderImpl
  
  assets: {}
  
  load: (@url, @callback) =>
    @manifest = Game.Http.getData(@url)
    @loader = new createjs.PreloadJS()
    @loader.installPlugin(createjs.SoundJS)
    #@loader.useXHR = false
    @loader.onFileLoad = @handleFileLoad
    @loader.onComplete = @handleComplete
    @loader.loadManifest(@manifest)
      
  handleFileLoad: (event) =>
    switch event.type
      when createjs.PreloadJS.IMAGE
        img = new Image()
        img.src = event.src
        @assets[event.id] = img
    
  handleComplete: =>
    @callback() if @callback
    
  get: (id) =>
    @assets[id]

  