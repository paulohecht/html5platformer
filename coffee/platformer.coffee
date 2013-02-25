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
    
    @camera = Game.Instances.createCamera(@stage)

    @map = new Game.TiledLoader()
    @map.on "instantiaterequest", @onInstantiateRequest
    @map.on "loaded", @onMapLoaded
    @map.render(@gameLayer, "assets/tiled/map.json")

    #stage updates (not really used here)
    createjs.Ticker.setFPS(30)
    createjs.Ticker.addListener(@)
    
    Game.Input.init()
    Game.Physics.init()
    
    Game.Popup.init(@popupLayer, "assets/speechs.json")
    Game.Popup.show("intro")
    
    Game.Audio.playBG("bg-music")
    
  onMapLoaded: =>
    @camera.setTarget(@player)
    @camera.setBounds(0, @map.getMapWidth())
    Game.Physics.createWorldLateralbounds(0, @map.getMapWidth(), @stage.canvas.height)
    
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
    @player.on "findprincess", @findPrincess
    
  respawnPlayer: =>
    @player.respawn(@playerSpawnX, @playerSpawnY)
    
  findPrincess: =>
    Game.Audio.playSFX("princess-sound") 
    Game.Popup.show("saved")
    
  instantiatePrincess: (x, y) =>
    princess = new Game.Princess()
    princess.render(@gameLayer, x, y)

  instantiateFish: (x, y) =>
    fish = new Game.Fish()
    fish.render(@gameLayer, x, y)

  tick: (elapsed) =>
    
    Game.Audio.toggleMuteBG() if (Game.Input.isKeyDown("m"))
    
    Game.Input.update()

    Game.Physics.update(elapsed)
    Game.Time.update(elapsed)

    Game.Popup.update()
    
    @camera.update()
    
    @gameLayer.x = -@camera.x
    @map.update()
    
    @stage.update()