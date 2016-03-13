# Description
#   Silly simple reminder script.
#
# Commands:
#
# Notes:
#
# Author:
#   liz hubertz

class Exercise

  constructor: (@robot) ->
    # Load in data for groups and exercises
    Fs = require 'fs'
    Path = require 'path'

    groupsFilePath = Path.resolve ".", "data", "groups.json"
    Fs.readFile groupsFilePath, (err, data) =>
      @groups = JSON.parse data

    exercisesFilePath = Path.resolve ".", "data", "exercises.json"
    Fs.readFile exercisesFilePath, (err, data) =>
      @exercises = JSON.parse data

    # Set cache for richard to save user data
    @users = {}
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.exercise
        @users = @robot.brain.data.users

    @finished_responses = [
      "is fabuloooous!",
      "twerk it gurl!",
      "has abs of STEEL",
      "has thighs of STEEL",
      "is a maaaaniac, MAAANIAC!",
      "didn't get that ass by sitting all day!",
      "FELT THE BURN",
      "woke up. worked out. kicked ass."
    ]

  remove: (username) ->
    user = @users[username]
    user.status = "inactive"
    @robot.brain.data.users = @users

  increment: (username) ->
    user = @users[username]
    @add(username) if !user
    @activate(username) if !(user.status == "active")
    user.score += 1
    timestamp = new Date().toUTCString();
    user.last_exercised_at = timestamp
    @robot.brain.data.users = @users

  activate: (username) ->
    preferences = @users[username]
    preferences.status = "active"
    @robot.brain.data.users = @users

  add: (username) ->
    return @activate(username) if @users[username]
    # TODO: This needs to be refactored so we're saving users as an array of
    # dictionaries, none of this hashtable BS with key as name.
    @users[username] = {
      "name" : username
      "score" : 0,
      "status" : "active",
      "groups" : "fitness",
      "last_exercised_at" : "TBD"
    }
    @robot.brain.data.users = @users
    return @users[username]

  list: ->
    user_list = []
    for name, preferences of @users
      unless preferences.status != "active"
        user_list.push({
          name: name,
          score: preferences.score,
          last_exercised_at: preferences.last_exercised_at,
        })
    return user_list

  finishedResponse: ->
    @finished_responses[Math.floor(Math.random() * @finished_responses.length)]

  listExercises: ->
    return @exercises

  listGroups: ->
    return @groups

  getGroupUsers: (slug) ->
    # group = @groups.filter(group) ->
    #   group.slug == slug
    # TODO: Implement new data model for users
    return @users.keys

  getRandomExercise: (slug) ->
    exercises = @exercises.filter (exercise) ->
      slug in exercise.groups
    return exercises[Math.floor(Math.random() * exercises.length)]

  random: (array) ->
    array[Math.floor(Math.random() * array.length)]

module.exports = (robot) ->
  richard = new Exercise robot

  # Richard should explain himself
  # May need to override help function in hubot
  # Source: https://github.com/github/hubot/issues/844
  ###############################

  robot.hear /hello/, (msg) ->
    user = msg.message.user.name
    message = "hello #{user}"
    msg.send message

  robot.respond /random/, (msg) ->
    message = ["Random Exercise:"]
    exercise = richard.getRandomExercise("fitness")
    message.push "#{exercise.title} - #{exercise.description}"
    msg.send message.join("\n")


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
  #############################

  robot.respond /add user (\S+[^-\s])$/i, (msg) ->
    username = msg.match[1].toLowerCase()
    richard.add username
    msg.send "Added user: #{username}"

  robot.respond /list users/i, (msg) ->
    message = ["The Springercisers:"]
    for user in richard.list()
      message.push "#{user.name} - *Score:* #{user.score}, *Last Exercised:* #{user.last_exercised_at}"
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

  # Send automated exercise instructions per group
  #############################

  robot.on "yoga", (msg) ->
    users = richard.getGroupUsers("yoga")
    exercise = richard.getRandomExercise("yoga")
    message = ["#{users} it's time to get moving!"]
    message.push "#{exercise.title}"
    message.push "#{exercise.description}"
    robot.send { room: "exercise" }, message.join("\n")

  robot.on ".+", (group_name) ->
    message = ["This is a fully automated exercise reminder for #{group_name}."]
    # for user, rank in richard.list()
    #   message.push "#{user.name}"
    robot.send { room: "exercise" }, message.join(" ")
