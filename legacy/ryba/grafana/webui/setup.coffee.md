
# Prometheus Install

    export default header: 'Grafana WEBUi Setup', handler: ({options}) ->
      beans = null
      rows = []
      exp = []
      {ini, url} = options

## Register

      @registry.register ['grafana', 'dashboard'], '@rybajs/metal/grafana/actions/grafana_dashboard'
      @registry.register ['grafana', 'datasource'], '@rybajs/metal/grafana/actions/grafana_datasource'

## Datasources

      @each options.datasources, ({options}, callback) ->
        {key, value} = options
        @grafana.datasource
          header: "#{key}"
          username: ini['security']['admin_user']
          password: ini['security']['admin_password']
          url: url
        , value
        @next callback

## Dashboards

      @each options.templates, ({options}, callback) ->
        {key, value} = options
        @grafana.dashboard
          username: ini['security']['admin_user']
          password: ini['security']['admin_password']
          url: url
        , value
        @next callback

## Dependencies

    quote = require 'regexp-quote'
    misc = require '@nikitajs/core/lib/misc'
    mkcmd = require '../../lib/mkcmd'
