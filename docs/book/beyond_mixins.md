# Beyond Mixins

This page defines a class called `Module` that can be used as a generic base class. `Module` will have two static functions, `extend` and `include`, which can be used for extending classes with static and instance properties respectively.

    moduleKeywords = ['extended', 'included']
    
    class Module
      @extend: (obj) ->
        for key, value of obj when key not in moduleKeywords
          @[key] = value
    
        obj.extended?.apply(@)
        this
    
      @include: (obj) ->
        for key, value of obj when key not in moduleKeywords
          # Assign properties to the prototype
          @::[key] = value
    
        obj.included?.apply(@)
        this
    
The little dance around the `moduleKeywords` variable is to ensure callback support when mixins extend a class.

Some example code:

    classProperties = 
      find: (id) ->
      create: (attrs) ->
    
    instanceProperties =
      save: -> 
    
    class User extends Module
      @extend classProperties
      @include instanceProperties
    
    # Usage:
    user = User.find(1)
    
    user = new User
    user.save()

This example adds two static properties, `find` and `create`, to the `User` class, as well as an instance property, `save`. With callback support, you can nicely shortcut the process of
applying both static and instance properties.

    ORM = 
      find: (id) ->
      create: (attrs) ->
      extended: ->
        @include
          save: -> 
    
    class User extends Module
      @extend ORM
