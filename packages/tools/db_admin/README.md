
# DB Admin

This service is a convenient facade towards multiple database services. Multiple
components derived their database configuration from this service. It must be 
provided if you use an external database like MySQL, MariaDB or PostgreSQL.

## Configuration

### Engine

Default engine based on service discovery. The option "engine" is set if a
suitable database is found and match a pre-configured provider. Possible values 
are 'mariadb', 'postgresql' and 'mysql' in this order of preference.

For exemple, an "engine" options set to "mariadb" reflect the discovery of an
instance of MariaDB and the existance of a usable db object available as the
"mariadb" option.

### Providers

A provider object contains commons properties and potentially database specific
properties. Commons properties are:

* `engine` (string)   
  One of the supported engine between "mariadb", "postgresql", "mysql", required.
* `admin_username` (string)   
  Administrator username.
* `admin_password` (string)   
  Administrator password.
* `java.driver` (string)   
  Java driver.
* `java.datasource` (string)   
  Java datasource.
* `jdbc` (string)   
  JDBC URL.
* `fqdns` ([string])   
  List of database FQDNs.
* `host` ([string])   
  Single database host for customers which doesn't support multi hosts or if a 
  proxy is configured.
* `port` (int)   
  Database server port.

### Exported configuration:

```jsonp
{
  "mariadb": {
    "engine": "mysql",
    "fqdns": ["mariadb-1.ryba", "mariadb-1.ryba"],
    "port": "3306",
    "admin_username": "test",
    "admin_password": "test123",
    "path": "mysql",
    "jdbc": "jdbc:mysql://master1.ryba:3306,master2.ryba:3306",
    "java": {
      "datasource": "org.mariadb.jdbc.MariaDbDataSource",
      "driver": "com.mysql.jdbc.Driver"
    }
  },
  "mysql": {
    "engine": "mysql",
    "fqdns": ["mysql-1.ryba", "mysql-2.ryba"],
    "port": "3306",
    "admin_username": "test",
    "admin_password": "test123",
    "path": "mysql",
    "jdbc": "jdbc:mysql://master1.ryba:3306,master2.ryba:3306",
    "java": {
      "datasource": "com.mysql.jdbc.Driver",
      "driver": "com.mysql.jdbc.Driver"
    }
  },
  postgresql: {
    "engine": "postgresql",
    "fqdns": ["postgresql-1.ryba", "postgresql-2.ryba"],
    "port": "5432",
    "admin_username": "test",
    "admin_password": "test123",
    "path": "mysql",
    "jdbc": "jdbc:postgresql://master1.ryba:3306,master2.ryba:3306",
    "java": {
      "datasource": "org.postgresql.jdbc2.Jdbc2PoolingDataSource",
      "driver": "org.postgresql.Driver"
    }
  },
  wait_mariadb: {}
  wait_mysql: {}
  wait_postgresql: {}
  wait: {
    tcp: [{
      host: 'mariadb-1.ryba', port: 3306
    }, {
      host: 'mariadb-2.ryba', port: 3306
    }]
  }
}
```

If an external database is used, mandatory properties should be hosts,
`admin_username` and `admin_password`.

`@rybajs/tools/db_admin` constructs the `jdbc_url`.

`[engine].host` is also generated in the final object to preserve compatibility with
lecacy versions.
