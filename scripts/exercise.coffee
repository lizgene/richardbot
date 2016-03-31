# Description
#   Silly simple reminder script.
#
# Commands:
#   hubot random - Gives a random exercise
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

    exercisesFilePath = Path.resolve ".", "data", "exercises.json"
    Fs.readFile exercisesFilePath, (err, data) =>
      @exercises = JSON.parse data

  listExercises: ->
    return @exercises

  getRandomExercise: (slug) ->
    exercises = @exercises.filter (exercise) ->
      slug in exercise.groups
    return exercises[Math.floor(Math.random() * exercises.length)]

  random: (array) ->
    array[Math.floor(Math.random() * array.length)]

module.exports = (robot) ->
  exercise_bot = new Exercise robot

  # List all exercises
  ##############################

  robot.respond /list exercises$/i, (msg) ->
    message = ["All Exercises:"]
    for exercise in exercise_bot.listExercises()
      message.push "#{exercise.title} - #{exercise.description} (#{exercise.groups.join(', ')})"

    msg.send message.join("\n")

  # Return a random exercise
  ##############################

  robot.respond /random/, (msg) ->
    message = ["Random Exercise:"]
    exercise = exercise_bot.getRandomExercise("fitness")
    message.push "#{exercise.title} - #{exercise.description}"
    msg.send message.join("\n")

  # TODO: terminate a specific person, add a funny message
  robot.respond /terminate/, (msg) ->
    message = ["Everybody up!!! It's time to exercise!!!!"]
    for user, rank in exercise_bot.list()
      message.push "#{user.name}"
    msg.send message.join(" ")

  # Blast a random exercise to a specific group
  #############################

  robot.on "blast", (blast) ->
    exercise = exercise_bot.getRandomExercise(blast.group)
    users = blast.users.join(' ')
    message = ["#{users} it's time to get moving!"]
    message.push "#{exercise.title}"
    message.push "#{exercise.description}"
    robot.send { room: "exercise" }, message.join("\n")
