class Game.Object extends Game.Behaviour
  
  tag: ""

  gameObject: null
  
  collider: null
  
  sprite: null
  
  components: =>
  
    
  addComponent: (component) =>
    #TODO: Check if instance of superclass...
    components.push(component)
    
  
    
    