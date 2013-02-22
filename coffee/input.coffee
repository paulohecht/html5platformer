class Game.Input
  
  _instance = undefined
  
  @instance: =>
    _instance ?= new Game.InputImpl()
    
  @init: =>
    @instance().init()
    
  @update: =>
    @instance().update()
    
  @isKeyPressed: (keyname) =>
    @instance().isKeyPressed(keyname)
    
  @isKeyDown: (keyname) =>
    @instance().isKeyDown(keyname)
    
  @isKeyUp: (keyname) =>
    @instance().isKeyUp(keyname)
  
class Game.InputImpl
  
  keycodes:
    "backspace": 8
    "tab": 9
    "enter": 13
    "shift": 16
    "ctrl": 17
    "alt": 18
    "pause": 19
    "capslock": 20
    "escape": 27
    "pageup": 33
    "pagedown": 34
    "end": 35
    "home": 36
    "left": 37
    "up": 38
    "right": 39
    "down": 40
    "insert": 45
    "delete": 46
    "semicolon": 186
    "comma": 188
    "period": 190
    "forwardslash": 191
    "backslash": 220
    "openbracket": 219
    "closebracket": 221
    "singlequote": 222
    "equal": 187
    "dash": 189
    #others are dynamically added like:
    #"0": 48  
    #"numpad0": 96  
    #"a": 65
    
  realtimePressedKeys: {}
  realtimeKeyDown: {}
  realtimeKeyUp: {}
  
  pressedKeys: {}
  keyDown: {}
  keyUp: {}
    
  generateAlphanumericMaps: =>
    @keycodes["#{num}"] = 48 + num for num in [0..9]
    @keycodes["numpad#{num}"] = 96 + num for num in [0..9]
    @keycodes["#{String.fromCharCode(char).toLowerCase()}"] = char for char in [65..90]
  
  init: =>
    @generateAlphanumericMaps()
    document.onkeydown = @handleKeyDown
    document.onkeyup = @handleKeyUp
    
  update: =>
    @pressedKeys = _.clone(@realtimePressedKeys)
    @keyDown = _.clone(@realtimeKeyDown)
    @keyUp = _.clone(@realtimeKeyUp)
    @realtimeKeyDown = {}
    @realtimeKeyUp = {}

  handleKeyDown: (e) =>
    return if @realtimePressedKeys[e.keyCode]
    @realtimePressedKeys[e.keyCode] = true
    @realtimeKeyDown[e.keyCode] = true
    
  handleKeyUp: (e) =>
    delete @realtimePressedKeys[e.keyCode]
    @realtimeKeyUp[e.keyCode] = true
    
  isKeyPressed: (keyname) =>
    keycode = @keycodes[keyname]
    keycode of @pressedKeys & @pressedKeys[keycode]

  isKeyDown: (keyname) =>
    keycode = @keycodes[keyname]
    keycode of @keyDown & @keyDown[keycode]

  isKeyUp: (keyname) =>
    keycode = @keycodes[keyname]
    keycode of @keyUp & @keyUp[keycode]