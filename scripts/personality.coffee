# Description
#   Adds a customized help command to give richard-specific instructions.
#   Adds other fun responses to give richard his unique personality.
#
# Commands:
#   richard help - Displays instructions to use richard's exercise commands.
#
# Notes:
#
# Author:
#   liz hubertz

module.exports = (robot) ->

  robot.hear /hello/, (msg) ->
    user = msg.message.user.name
    message = "hello #{user}"
    msg.send message

  robot.hear /where is everybody/, (msg) ->
    message = "@channel, I'm here!"
    msg.send message

  # Helper command with detailed instructions on how to make the most of richard
  robot.hear /how do i/i, (msg) ->
    message = "I have no idea. Geen idea!"
    msg.send message
