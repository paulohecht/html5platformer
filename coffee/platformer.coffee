class Game.Platformer
  
  init: =>
    
    if (!createjs.SoundJS.checkPlugin(true))
      alert("plugin error!")
      return
    
    Game.Preloader.load("assets/manifest.json", @onLoad)

  onLoad: =>
    #creating EaselJS stage
    @stage = Game.Instances.createStage("canvas")
    
    @gameLayer = new createjs.Container()
    @hudLayer = new createjs.Container()
    @popupLayer = new createjs.Container()
    @stage.addChild(@gameLayer, @hudLayer, @popupLayer)
    
    @fishs = []
    
    @mapLoader = new Game.TiledLoader()
    @mapLoader.on "instantiaterequest", @onInstantiateRequest
    @mapLoader.on "loaded", @onMapLoaded
    @mapLoader.render(@gameLayer, "assets/tiled/map.json")


    #stage updates (not really used here)
    createjs.Ticker.setFPS(30)
    createjs.Ticker.addListener(@)
    
    Game.Input.init()
    Game.Physics.init()
    
    Game.Popup.init(@popupLayer, "assets/speechs.json")
    Game.Popup.show("intro")
    
    Game.Audio.playBG("bg-music")
    
    @camera = Game.Instances.createCamera(@stage)
    
  onMapLoaded: =>
    @camera.setTarget(@player)
    @camera.setBounds(0, @mapLoader.getMapWidth())
    Game.Physics.createWorldLateralbounds(0, @mapLoader.getMapWidth(), @stage.canvas.height)
    
  onInstantiateRequest: (data, x, y) =>
    switch data.class
      when "player" then @instantiatePlayer(x, y)
      when "princess" then @instantiatePrincess(x, y)
      when "fish" then @instantiateFish(x, y)
      else alert "error: unknown class found in tiled map" 
      
  instantiatePlayer: (x, y) =>
    @playerSpawnX = x
    @playerSpawnY = y
    @player = Game.Instances.createPlayer()
    @player.render(@gameLayer, x, y)
    @player.on "die", @respawnPlayer
    
  respawnPlayer: =>
    @player.respawn(@playerSpawnX, @playerSpawnY)
    
  instantiatePrincess: (x, y) =>
    princess = new Game.Princess()
    princess.render(@gameLayer, x, y)

  instantiateFish: (x, y) =>
    fish = new Game.Fish()
    fish.render(@gameLayer, x, y)

  tick: (elapsed) =>
    
    Game.Audio.toggleMuteBG() if (Game.Input.isKeyDown("m"))
    
    Game.Physics.update(elapsed)
    Game.Input.update()
    Game.Popup.update()
    
    @player.update(elapsed) if @player
    
    @camera.update()
    
    @gameLayer.x = -@camera.x
    
    @stage.update()