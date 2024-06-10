
# Hue Start

Start the Hue server. You can also start the server manually with the following
command:

```
service hue start
```

    export default header: 'Hue Start', handler: ->
      @service.start name: 'hue'
