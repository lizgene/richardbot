# Description
#   Adds and removes users from the exercisers list.
#
# Commands:
#   hubot add [me|username] - Add yourself or another member as an exerciser
#   hubot [remove|stop|delete] [me|username]
#   hubot list [members|users|exercisers] - List exercisers
#
# Notes:
#
# Author:
#   liz hubertz

class Exerciser

  constructor: (@robot) ->

  # Set cache for hubot to save user data
  @exercisers = []
  @robot.brain.on 'loaded', =>
    if @robot.brain.data.exercisers
      @exercisers = @robot.brain.data.exercisers

 # Updates the brain
 updateBrain = (exercisers) ->
   @robot.brain.data.exercisers = exercisers

  # Return all exercisers
  getExercisers = ->
    @exercisers

  # Get specific exercisers
  getExerciser = (username) ->
    _.where @exercisers, name: username

  removeExerciser = (username) ->
    for exerciser in @exercisers
      exerciser.status = "inactive" if exerciser.name == username
    updateBrain(@exercisers)

  activateExerciser = (username) ->
    for exerciser in @exercisers
      exerciser.status = "active" if exerciser.name == username

  # Add a new exerciser or activate one who already exists.
  addExerciser = (username) ->
    activateExerciser(username) if getExerciser(username)

    new_exerciser = {
      name: username,
      status: "active",
      score: 0,
      groups: ["fitness"],
      last_exercised_at: "TBD"
    }
    @exercisers.push(new_exerciser)
    updateBrain(@exercisers)

  # Get a point for exercising!
  levelUp = (username) ->
    # Add or update exerciser in case they don't exist or are inactive.
    @addExerciser(username)
    for exerciser in @exercisers
      if exerciser.name == username
        exerciser.score += 1
        exerciser.last_exercised_at = new Date().toUTCString()
    updateBrain(@exercisers)

module.exports = (robot) ->
  richard = new Exerciser robot

  # Listing groups and exercises
  ##############################

  robot.respond /list groups/, (msg) ->
    message = ["All Groups:"]
    for group in richard.listGroups()
      message.push "#{group.title} - #{group.description}"
    msg.send message.join("\n")

  robot.respond /list exercises/, (msg) ->
    message = ["All Exercises:"]
    for exercise in richard.listExercises()
      message.push "#{exercise.title} - #{exercise.description}"
    msg.send message.join("\n")

  # Creating and updating users
  ##############################

  robot.respond /add user (\S+[^-\s])$/i, (msg) ->
    username = msg.match[1].toLowerCase()
    richard.add username
    msg.send "Added user: #{username}"

  robot.respond /list users/i, (msg) ->
    message = ["The Springercisers:"]
    for user in richard.list()
      message.push "#{user.name} - *Score:* #{user.score}, *Last Exercised:* #{user.last_exercised_at}, *Groups:* #{user.groups}"
    msg.send message.join("\n")

  robot.respond /terminate/, (msg) ->
    message = ["Everybody up!!! It's time to exercise!!!!"]
    for user, rank in richard.list()
      message.push "#{user.name}"
    msg.send message.join(" ")

  robot.respond /remove (\S+[^-\s])$/i, (msg) ->
    user = msg.match[1].toLowerCase()
    richard.remove user
    msg.send "Removed user: #{user}"

  robot.hear /done/i, (msg)  ->
    user = msg.message.user.name
    richard.increment user
    msg.send "#{user} #{richard.finishedResponse()}"

  # robot.hear /yoga/i, (msg) ->
  #   users = richard.getGroupUsers("fitness")
  #   exercise = richard.getRandomExercise("fitness")
  #   message = ["#{users} it's time to get moving!"]
  #   message.push "#{exercise.title}"
  #   message.push "#{exercise.description}"
  #   robot.send { room: "exercise" }, message.join("\n")

  # Send automated exercise instructions per group
  #############################

  robot.on "fitness", (msg) ->
    users = richard.getGroupUsers("fitness")
    exercise = richard.getRandomExercise("fitness")
    message = ["#{users} it's time to get moving!"]
    message.push "#{exercise.title}"
    message.push "#{exercise.description}"
    robot.send { room: "exercise" }, message.join("\n")

  robot.on ".+", (group_name) ->
    message = ["This is a fully automated exercise reminder for #{group_name}."]
    # for user, rank in richard.list()
    #   message.push "#{user.name}"
    robot.send { room: "exercise" }, message.join(" ")
