---
title: Make
layout: page
---

# Make

Install the GNU make utility to maintain groups of programs.

This action does not use any configuration.

    module.exports = []
    module.exports.push 'phyla/bootstrap'
    module.exports.push 'phyla/core/yum'

## Package

The package "make" is installed upon execution.

    module.exports.push name: 'Make # Package', timeout: -1, callback: (ctx, next) ->
      ctx.service
        name: 'make'
      , (err, serviced) ->
        next err, if serviced then ctx.OK else ctx.PASS
