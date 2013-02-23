#TODO: Support multiple tilesets.
#TODO: Keep each layer on a different Container to handle z order.

TILESET_IDX = 0

class Game.TiledLoader extends Game.Mixable
  
  mixins: [Game.Events]
  
  mapCols: 0
  
  render: (@stage, @url) =>
    tokens = @url.split("/")
    tokens.pop()
    @path = tokens.join("/")
    @mapData = Game.Http.getData(@url)

    #create EaselJS image for tileset
    #getting imagefile from first tileset
    @tileset = new Image()
    @tileset.onload = @initLayers
    @tileset.src = "#{@path}/#{@mapData.tilesets[TILESET_IDX].image}"
  	#callback for loading layers after tileset is loaded

  getMapWidth: =>
    @mapCols * @mapData.tilewidth

  #loading layers
  initLayers: =>
    imageData =
      images: [@tileset]
      frames:
      	width: @mapData.tilewidth
      	height: @mapData.tilewidth
    
    #create spritesheet
    @tilesetSheet = new createjs.SpriteSheet(imageData)
    
    #loading each layer at a time
    for idx in [0..@mapData.layers.length - 1]
      layerData = @mapData.layers[idx]
      @initLayer(layerData)
    @trigger "loaded"

  #layer initialization
  initLayer: (layerData) =>
    
    for row in [0..layerData.height - 1]
    	for col in [0..layerData.width - 1]
        idx = layerData.data[(col + row * layerData.width)] - 1
    	  
        unless layerData.properties && layerData.properties.parallax
          if (idx != -1) 
            @mapCols = col + 1 if (@mapCols < col + 1)
    	  
        x = col * @mapData.tilewidth
        y = row * @mapData.tileheight
        tileData = @mapData.tilesets[TILESET_IDX].tileproperties[idx]
        if tileData && "class" of tileData
          @trigger "instantiaterequest", tileData, x, y
        else
          tile = new Game.Tile()
          tile.render(@stage, @tilesetSheet, idx, x, y, tileData)