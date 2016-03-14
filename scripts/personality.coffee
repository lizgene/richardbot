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

  # Helper command with detailed instructions on how to make the most of richard
  robot.hear /how do i/i, (msg) ->
    message = "
      Great question! Here are some tips on how to use the exercise channel:\n\n
      *How to start/stop exercise notifications:*\n
      richard add [username]\n
        \tAdd yourself or friends to the exercise channel! You'll be added to our default fitness group to start.\n
      richard remove [username]\n
        \tNo more notifications for you. But don't worry, your score will still be here when you come back. Just say 'richard add me' to jump back in.\n
      richard list users\n
        \tFind out which of your friends are awesome, and their current score!\n
      \n
      *See available workouts:*\n
      richard list exercises\n
        \tSee which exercises we currently have in our database. Ask a friendly dev if you want to update this list.\n
      richard list groups\n
        \tSee which exercise groups are currently active. Ask a friendly dev if you want to update this list.\n
      \n
      *Exercise time:*\n
      richard random\n
        \tGet a random exercise at any time.\n
      I'm done!\n
        \tSay the word 'done' to let me know you've completed a workout. Your score will go up!
    "
    msg.send message
