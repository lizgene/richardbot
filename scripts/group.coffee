# Description
#   Manages the exercise group list.
#
# Commands:
#   hubot list groups - List current groups
#   hubot show group [group_slug] - Show info on a specific group
#
# Notes:
#
# Author:
#   liz hubertz

class Group

  constructor: (@robot) ->
    # TODO: Make groups addable/editable by users by saving them in the brain
    # Load in data for groups
    Fs = require 'fs'
    Path = require 'path'

    groupsFilePath = Path.resolve ".", "data", "groups.json"
    Fs.readFile groupsFilePath, (err, data) =>
      @groups = JSON.parse data

  listGroups: ->
    @groups

  getGroup: (slug) ->
    for group in @groups
      return group if group.slug == slug

module.exports = (robot) ->
  group_bot = new Group robot

  # List all groups
  ##############################

  robot.respond /list groups$/i, (msg) ->
    message = ["All Groups:"]
    for group in group_bot.listGroups()
      message.push "#{group.title} (for more info: 'show group #{group.slug}')"

    msg.send message.join("\n")

  # Show info on a specific group
  ##############################

  robot.respond /show group (\S+[^-\s])$/i, (msg) ->
    slug = msg.match[1].toLowerCase()
    group = group_bot.getGroup(slug)
    message = ["*#{group.title}*", "_#{group.description}_", "Magic cron schedule: #{group.schedule}"].join("\n")

    msg.send message
