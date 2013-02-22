class Game.Popup
  
  _instance = undefined
  
  @instance: =>
    _instance ?= new Game.PopupImpl()
    
  @init: (stage, url) =>
    @instance().init(stage, url)
    
  @show: (speech) =>
    @instance().show(speech)
    
  @update: =>
    @instance().update()
  
class Game.PopupImpl
  
  visible: false
  
  init: (@stage, @url) =>
    
    data = Game.Http.getData(@url)
    
    @characters = data.characters
    @speechs = data.speechs
    
    @popup = new createjs.Container()
    
    ###
    @bg = new createjs.Shape()
    g = @bg.graphics
    g.setStrokeStyle(5, 'round', 'round')
    g.beginStroke('#000000')
    g.beginFill("#FFFFFF")
    g.drawRect(90, 20, 500, 100)
    g.endStroke()
    g.endFill()
    ###
    
    @bg = new createjs.Bitmap(Game.Preloader.get("popup"))
    @bg.x = 90
    @bg.y = 20
    
    @avatar = new createjs.Bitmap()
    @avatar.x = 100
    @avatar.y = 30
    
    @name = new createjs.Text("", "14px Arial", "#444444")
    @name.textAlign = 'center'
    @name.textBaseline= 'top'
    @name.x = 124
    @name.y = 80
    
    text = ""
    @text = new createjs.Text(text, "14px Arial", "#444444")
    @text.textAlign = 'center'
    @text.textBaseline= 'top'
    @text.x = 360
    @text.y = 30
    @text.width = 400
    @text.lineWidth = @text.width
    
    @continue = new createjs.Text("[enter] continue", "12px Arial", "#00cc00")
    @continue.x = 400
    @continue.y = 100
    
    @skip = new createjs.Text("[escape] skip", "12px Arial", "#cc0000")
    @skip.x = 500
    @skip.y = 100
    
    @popup.addChild(@bg, @avatar, @name, @text, @continue, @skip)
    
  update: =>
    return unless @visible
    @next() if (Game.Input.isKeyUp("enter"))
    @hide() if (Game.Input.isKeyPressed("escape"))
  
  show: (@speech) =>
    @visible = true
    @speechIndex = 0
    @updateSpeech()
    @stage.addChild(@popup)

  next: =>
    @speechIndex++
    @updateSpeech()
    
  hide: =>
    @visible = false
    @stage.removeChild(@popup)
    
  updateSpeech: =>
    speechData = @speechs[@speech]
    currentSpeechData = speechData[@speechIndex]
    
    return @hide() unless (@speechIndex < speechData.length)
    
    characterData = @characters[currentSpeechData.character]
    @avatar.image = Game.Preloader.get(characterData.avatar)
    @name.text = characterData.name
    @text.text = currentSpeechData.text
    if (@speechIndex < speechData.length - 1)
      @popup.addChild(@continue)
    else
      @popup.removeChild(@continue)