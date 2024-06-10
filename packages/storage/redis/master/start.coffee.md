
# Redis Master Start

Simply start the Master service by running:

```bash
  service redis start
```

    export default header: 'Redis Master Start', handler: (options) ->
      @service.start
        name: 'redis'
