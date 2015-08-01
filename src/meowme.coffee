# Description:
#   Meow makes your everyday is Caturday
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot meow me <category> - Receive a cat. <category> is optional
#   hubot meow bomb <category> N - Receive N cats. <category> is optional
#   hubot meow categories - List categories

$ = require 'cheerio'
base = 'http://thecatapi.com/api'


# @see https://gist.github.com/sheldonh/6089299
merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs

tap = (o, fn) -> fn(o); o


getImagesGetUrl = (options = {}) ->
  url = base + '/images/get'
  defaults =
    format: 'xml'

  options = merge defaults, options
  queries = (encodeURIComponent(k) + '=' +
             encodeURIComponent(v) for k, v of options)
  url = url + '?' + queries.join('&')

  return url


module.exports = (robot) ->
  robot.respond /meow me( (\w+))?/i, (msg) ->
    category = msg.match[2] || ''
    options = {}

    if category
      options['category'] = category

    url = getImagesGetUrl options

    msg.http(url)
      .get() (err, res, body) ->
        images = $(body).find 'image'

        if images.length
          msg.send $(image).find('url').text() for image in images
        else
          msg.send 'No cats found.'

  robot.respond /meow bomb( ([A-Za-z]\w+))?( (\d+))?/i, (msg) ->
    count = msg.match[4] || 5
    category = msg.match[2] || ''
    options =
      results_per_page: count

    if category
      options['category'] = category

    url = getImagesGetUrl options

    msg.http(url)
      .get() (err, res, body) ->
        images = $(body).find 'image'

        if images.length
          msg.send $(image).find('url').text() for image in images
        else
          msg.send 'No cats found.'

  robot.respond /meow categories/i, (msg) ->
    url = base + '/categories/list'

    msg.http(url)
      .get() (err, res, body) ->
        category_nodes = $(body).find 'name'
        categories = ($(x).text() for x in category_nodes)
        message = categories.join '\n'

        msg.send message
