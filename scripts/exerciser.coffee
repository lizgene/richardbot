# Description
#   Manages the exerciser list.
#
# Dependencies:
#   "underscore": "^1.8.3"
#
# Commands:
#   hubot add [me|username] - Add yourself or another member as an exerciser
#   hubot stop - Remove yourself as an exerciser
#   hubot done - Give yourself a point for exercising
#   hubot [list|stats] - List exercisers and their stats
#
# Notes:
#
# Author:
#   liz hubertz

_ = require("underscore")

class Exerciser

  constructor: (@robot) ->

    # Set cache for hubot to save user data
    @exercisers = []
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.exercisers
        @exercisers = @robot.brain.data.exercisers

    @kudos = [
      "is fabuloooous!",
      "twerk it gurl!",
      "has abs of STEEL",
      "has thighs of STEEL",
      "is a maaaaniac, MAAANIAC!",
      "didn't get that ass by sitting all day!",
      "FELT THE BURN",
      "woke up. worked out. kicked ass."
    ]

  # Updates the brain
  updateBrain: (exercisers) ->
   @robot.brain.data.exercisers = exercisers

  # Return all exercisers
  getExercisers: ->
    _.where @exercisers, status: "active"

  getGroupMembers: (slug) ->
    members = _.filter @exercisers, (exerciser) -> slug in exerciser.groups
    return _.map members, (member) -> member.name

  # Get specific exerciser
  getExerciser: (username) ->
    _.where @exercisers, name: username

  removeExerciser: (username) ->
    for exerciser in @exercisers
      exerciser.status = "inactive" if exerciser.name == username
    @updateBrain(@exercisers)

  # Add a new exerciser or activate one who already exists.
  addExerciser: (username) ->
    exerciser = @getExerciser(username)
    if exerciser.count > 1
      exerciser.status = "active"
      return

    else
      new_exerciser = {
        name: username,
        status: "active",
        score: 0,
        groups: ["fitness"],
        last_exercised_at: "TBD"
      }
      @exercisers.push(new_exerciser)
      @updateBrain(@exercisers)

  # Get a point for exercising!
  levelUp: (username) ->
    # Add or update exerciser in case they don't exist or are inactive.
    @addExerciser(username) if !@getExerciser(username)
    exerciser = @getExerciser(username)
    exerciser.score +=1
    exerciser.last_exercised_at = new Date().toUTCString()
    @updateBrain(@exercisers)

  # Send a happy response when a user finishes an exercise
  getKudos: ->
    @kudos[Math.floor(Math.random() * @kudos.length)]

module.exports = (robot) ->
  exerciser_bot = new Exerciser robot

  # Create and removing exercisers
  ##############################

  robot.respond /add (\S+[^-\s])$/i, (msg) ->
    current_user = msg.message.user.name
    added_user = msg.match[1].toLowerCase()

    if (current_user != added_user) && (added_user != "me")
      message = "#{current_user} you sneaky snake. I'll add #{added_user}, but just this once. ;-)"
      exerciser_bot.addExerciser(added_user)
    else
      message = "Awesome, #{current_user}, you are added to my list!"
      exerciser_bot.addExerciser(current_user)

    msg.send message

  robot.respond /stop$/i, (msg) ->
    current_user = msg.message.user.name
    message = "#{current_user}, sorry to see you go. Come back any time!"
    exerciser_bot.removeExerciser(current_user)

    msg.send message

  # Update exercisers
  ##############################

  robot.hear /done/i, (msg)  ->
    current_user = msg.message.user.name
    exerciser_bot.levelUp(current_user)
    msg.send "#{current_user} #{exerciser_bot.getKudos()}"

  # List exercisers
  ##############################

  robot.respond /(list|stats)$/i, (msg) ->
    message = ["The Springercisers:"]
    for user in exerciser_bot.getExercisers()
      message.push "#{user.name} - *Score:* #{user.score}, *Last Exercised:* #{user.last_exercised_at}, *Groups:* #{user.groups}"
    msg.send message.join("\n")

  # Trigger automated exercise instructions when a cron job emits its slug
  #############################

  robot.on "fitness", (msg) ->
    users = exerciser_bot.getGroupMembers("fitness")
    robot.emit "blast", {
     users: [users]
     group: "fitness"
    }

  robot.on "yoga", (msg) ->
    users = exerciser_bot.getGroupMembers("yoga")
    robot.emit "blast", {
     users: [users]
     group: "yoga"
    }
