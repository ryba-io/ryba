
# Hive Metastore Install

    export default  header: 'Hive Metastore Install', handler: ({options}) ->

## Register

      @registry.register 'hdp_select', '@rybajs/metal/lib/hdp_select'

## SQL Connectors

      @call
        header: 'MySQL Client'
        if: options.db.engine in ['mariadb', 'mysql']
      , ->
        @service
          name: 'mysql'
        @service
          name: 'mysql-connector-java'
      @call
        header: 'Postgres Client'
        if: options.db.engine is 'postgresql'
      , ->
        @service
          name: 'postgresql'
        @service
          name: 'postgresql-jdbc'

## Metastore DB

      @call header: 'Metastore DB', ->
        @db.user options.db, database: null,
          header: 'User'
          if: options.db.engine in ['mariadb', 'postgresql', 'mysql']
        @db.database options.db,
          header: 'Database'
          user: options.db.username
          if: options.db.engine in ['mariadb', 'postgresql', 'mysql']
        @db.schema options.db,
          header: 'Schema'
          if: options.db.engine is 'postgresql'
          schema: options.db.schema or options.db.database
          database: options.db.database
          owner: options.db.username
