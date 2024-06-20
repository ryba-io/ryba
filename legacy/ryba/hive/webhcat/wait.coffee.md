
# WebHCat Wait

    export default header: 'WebHCat Wait', handler: ({options}) ->

## HTTP Port

      @connection.wait
        header: 'HTTP'
        servers: options.http

## Dependencies

    mkcmd = require '../../lib/mkcmd'
