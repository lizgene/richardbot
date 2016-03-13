Helper = require('hubot-test-helper')
expect = require('chai').expect
co = require('co')

# helper loads a specific script if it's a file
helper = new Helper('./../scripts/exercise.coffee')

describe 'hello', ->

  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user says hi to robot', ->
    beforeEach ->
      co =>
        yield @room.user.say 'alice', 'hubot hello'
        yield @room.user.say 'bob',   'hubot hello'

    it 'should reply to user', ->
      expect(@room.messages).to.eql [
        ['alice', 'hubot hello']
        ['hubot', 'hello alice']
        ['bob',   'hubot hello']
        ['hubot', 'hello bob']
      ]
