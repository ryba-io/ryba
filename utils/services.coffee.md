---
title: 
layout: module
---

# Services

    each = require 'each'
    mecano = require 'mecano'
    module.exports = []
    module.exports.push 'phyla/bootstrap'
    module.exports.push 'phyla/core/yum'

    module.exports.push (ctx) ->
      ctx.config.services ?= []

    module.exports.push name: 'Service # Install', timeout: -1, callback: (ctx, next) ->
      serviced = 0
      {services} = ctx.config
      each(services)
      .on 'item', (service, next) ->
        service = name: service if typeof service is 'string'
        ctx.service service, (err, s) ->
          serviced += s
          next err
      .on 'both', (err) ->
        next err, if serviced then ctx.OK else ctx.PASS
