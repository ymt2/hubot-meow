# Description:
#   Meowme makes your everyday is Caturday
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot meow me - Receive a cat
#   hubot meow bomb N - Receive N cats

$ = require 'cheerio'
base = 'http://thecatapi.com/api'


module.exports = (robot) ->
  robot.respond /meow me/i, (msg) ->
    url = base + '/images/get?format=xml'

    msg.http(url)
      .get() (err, res, body) ->
        images = $(body).find 'image'
        msg.send images[0].text()

  robot.respond /meow bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    url = base + '/images/get?format=xml&results_per_page=' + count

    msg.http(url)
      .get() (err, res, body) ->
        images = $(body).find 'image'
        msg.send $(image).find("url").text() for image in images
