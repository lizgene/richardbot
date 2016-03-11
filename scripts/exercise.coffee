# Description
#   Silly simple reminder script.
#
# Commands:
#
# Notes:
#
# Author:
#   liz hubertz

module.exports = (robot) ->

  robot.on "exercise:reminder", (status_reminder) ->
    robot.send { room: "exercise" }, "Everybody exercise!"
