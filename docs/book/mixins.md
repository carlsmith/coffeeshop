# Mixins

[Mixins](http://en.wikipedia.org/wiki/Mixin) are not explicitly supported in CoffeeScript; you just implement them yourself. For example, here's two functions, `extend` and
`include` that add class and instance properties, respectively, to a class.

    
    extend = (obj, mixin) ->
      obj[name] = method for name, method of mixin        
      obj
    
    include = (klass, mixin) ->
      extend klass.prototype, mixin
    
    # Usage
    include Parrot,
      isDeceased: true
    
    (new Parrot).isDeceased

One advantage of mixins is that you can mash them up; with inheritance, only one class can be inherited from.