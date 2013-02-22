class Game.Http

  @get: (url) =>
    xmlHttp = null
    xmlHttp = new XMLHttpRequest()
    xmlHttp.open("GET", url, false)
    xmlHttp.send(null)
    xmlHttp.responseText
  
  @getData: (url) =>
    responseText = Game.Http.get(url)
    JSON.parse(responseText)