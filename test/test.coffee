should = require('chai').should()
Backbone = require 'backbone'
require '../'

class Model extends Backbone.Model
  idAttribute: ['a', 'b']

class Collection extends Backbone.Collection
  model: Model

describe 'composite keys', ->
  it 'should be available in `initialize`', ->
    id = null
    Model::initialize = -> id = @id
    new Model a: 1, b: 2
    id.should.equal '1-2'

  it 'should change when `silent: true`', ->
    a = new Model a: 1, b: 2
    a.id.should.equal '1-2'
    a.set {b: 1}, silent: true
    a.id.should.equal '1-1'

  it 'should update collection index when changed', ->
    a = new Model a: 1, b: 2
    b = new Collection
    b.add a
    b.get('1-2').should.equal a
    a.set b: 1
    (b.get('1-2') is undefined).should.be.true
    b.get('1-1').should.equal a

  it 'should not repeat in collections', ->
    a = new Model a: 1, b: 2
    b = new Model a: 1, b: 2
    c = new Collection
    c.add a
    c.add b
    c.length.should.equal 1
    c.models.should.include a
    c.models.should.not.include b

  it 'should get unsaved models', ->
    (new Collection(a = new Model)).get(a).should.equal a

  it 'should get saved models', ->
    a = new Model a: 1, b: 1
    (c = new Collection a).get('1-1').should.equal a
    a.set b: 2
    c.get('1-2').should.equal a
    (c.get('1-1') is undefined).should.be.true
