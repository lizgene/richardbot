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
    @cache = {}

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

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.exercise
        @cache = @robot.brain.data.exercise

  remove: (thing) ->
    delete @cache[thing]
    @robot.brain.data.exercise = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.exercise = @cache

  list: ->
    my_list = []
    for key, value of @cache
      my_list.push({ name: key, score: value })
    return my_list

  finishedResponse: ->
    @finished_responses[Math.floor(Math.random() * @finished_responses.length)]

module.exports = (robot) ->
  richard = new Exercise robot

  robot.respond /add user (\S+[^-\s])$/i, (msg) ->
    user = msg.match[1].toLowerCase()
    richard.increment user
    msg.send "Added user: #{user}"

  robot.respond /list users/i, (msg) ->
    message = ["The Exercisers:"]
    for user, rank in richard.list()
      message.push "#{user.name} - #{user.score}"
    msg.send message.join("\n")

  robot.on "exercise:reminder", (msg) ->
    message = ["Everybody up!!! It's time to exercise!!!!"]
    for user, rank in richard.list()
      message.push "#{user.name}"
    robot.send message.join(" ")

  robot.respond /terminate/, (msg) ->
    message = ["Everybody up!!! It's time to exercise!!!!"]
    for user, rank in richard.list()
      message.push "#{user.name}"
    msg.send message.join(" ")

  robot.respond /remove user (\S+[^-\s])$/i, (msg) ->
    # user = msg.message.user.name
    user = msg.match[1].toLowerCase()
    richard.remove user
    msg.send "Removed user: #{user}"

  robot.hear /done/i, (msg)  ->
    user = msg.message.user.name
    richard.increment user
    msg.send "#{user} #{richard.finishedResponse()}"

  #
  # robot.respond /add exercise title:(.+).+description:(.+)/, (msg) ->
  #   title = msg.match[1].toLowerCase()
  #   description = msg.match[1].toLowerCase()
  #   exercise =
  #     title: title
  #     description: description
  #   robot.brain.data.exercise.exercises.push exercise
  #   msg.send "Added exercise: \n#{exercise.title}\n#{exercise.description}"
