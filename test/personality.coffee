# Dependencies
#   npm install mocha -g
#   npm install co
#   npm install chai
#   npm install coffee-script
#
# Run the tests
#   npm run test

Helper = require('hubot-test-helper')
expect = require('chai').expect
co = require('co')

# helper loads a specific script if it's a file
helper = new Helper('./../scripts/personality.coffee')

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

  context 'user says where is everybody', ->
    beforeEach ->
      co =>
        yield @room.user.say 'alice', 'where is everybody?'

    it 'should reply to user', ->
      expect(@room.messages).to.eql [
        ['alice', 'where is everybody?']
        ['hubot', "@channel, I'm here!"]
      ]

  context 'user says how do i...', ->
    beforeEach ->
      co =>
        yield @room.user.say 'alice', 'how do i do this?'

    it 'should reply to user', ->
      expect(@room.messages).to.eql [
        ['alice', 'how do i do this?']
        ['hubot', "I have no idea. Geen idea!"]
      ]
