
export default
  deps:
    mariadb: module: 'masson/commons/mariadb/server'
    postres: module: 'masson/commons/postgres/server'
    mysql: module: 'masson/commons/mysql/server'
  configure:
    '@rybajs/tools/db_admin/configure'
