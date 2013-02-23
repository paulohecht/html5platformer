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
    
    tiledloader = new Game.TiledLoader()
    tiledloader.render(@gameLayer, "assets/tiled/map.json")

    tiledloader.on "instantiaterequest", @onInstantiateRequest

    #stage updates (not really used here)
    createjs.Ticker.setFPS(30)
    createjs.Ticker.addListener(@)
    
    Game.Input.init()
    Game.Physics.init()
    
    Game.Popup.init(@popupLayer, "assets/speechs.json")
    Game.Popup.show("intro")
    
    Game.Audio.playBG("bg-music")
    
    
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
    
    @stage.update()

