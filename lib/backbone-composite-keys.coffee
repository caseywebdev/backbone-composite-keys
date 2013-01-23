_ = window?._ or require 'underscore'
Backbone = window?.Backbone or require 'backbone'

# Save the original `set`
set = Backbone.Model::set

generateId = (idAttr, attrs) ->
  return attrs[idAttr] if typeof idAttr is 'string'
  indexes = []
  for index in idAttr
    return undefined unless (val = attrs[index])?
    indexes.push val
  indexes.join '-'

idChangeEvents = (idAttr) ->
  return ["change:#{idAttr}"] if typeof idAttr is 'string'
  _.map idAttr, (index) -> "change:#{index}"

_.extend Backbone.Model::,

  # Generate an id base on `idAttribute`
  _generateId: (attrs = @attributes) -> generateId @idAttribute, attrs

  set: (key, val, options) ->
    return @ unless key?
    if _.isObject key
      attrs = key
      options = val
    else
      (attrs = {})[key] = val
    return false unless @_validate attrs, options || {}
    @id = @_generateId _.extend {}, @attributes, attrs
    set.apply @, arguments

# Save the original `_onModelEvent`
_onModelEvent = Backbone.Collection::_onModelEvent

_.extend Backbone.Collection::,
  get: (id) ->
    return undefined unless id?
    @_idAttr or= @model::idAttribute
    id = id.id || id.cid || generateId(@_idAttr, id) if _.isObject id
    this._byId[id]

  _onModelEvent: (event, model, collection, options) ->
    if event in idChangeEvents (@_idAttr or= @model::idAttribute)
      prev = generateId @_idAttr, model.previousAttributes()
      if prev isnt model.id
        delete @_byId[prev]
        @_byId[model.id] = model if model.id?
    _onModelEvent.apply @, arguments
