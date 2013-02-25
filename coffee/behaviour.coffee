class Game.Behaviour extends Game.Mixable
  
  mixins: [Game.Events]

  constructor: (args...) ->
    
    if @__proto__["update"]
      Game.Time.on("update", @update)

    if @__proto__["lateUpdate"]
      Game.Time.on("lateupdate", @lateUpdate)

    if @__proto__["fixedUpdate"]
      Game.Physics.on("update", @fixedUpdate)

    super()
    @initialize(args...) if @__proto__["initialize"]    