class Game.Mixable
  
  mixins: []
  
  constructor: ->
    _.extend(@, mixin) for mixin in @mixins