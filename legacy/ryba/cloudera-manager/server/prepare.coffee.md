
# Cloudera Manager Server Prepare

Resources:

*   [Cloudera Manager Install](http://www.cloudera.com/documentation/enterprise/latest/topics/cm_ig_install_path_c.html)
*   [Cloudera Manager Download](http://www.cloudera.com/documentation/enterprise/release-notes/topics/cm_vd.html)
*   [Parcels](http://www.cloudera.com/documentation/enterprise/latest/topics/cm_ig_create_local_parcel_repo.html#concept_y2w_13s_zr)
*   [Labs](http://www.cloudera.com/developers/cloudera-labs.html)

## Options

*   `cdh_version` (string)   
*   `distrib` (string, default "el6")   
    One of "el5", "el6", "el7", "precise", "sles11", "trusty", "wheezy".   
*   `services` (array)   
    Services to download. Valid services include "cdh5", "accumulo",
    "sqoop-connectors"

## Running

```coffee
coffee -s <<COFFEE
m = require 'nikita'
m.register 'cm_prepare', '@rybajs/metal/cloudera-manager/server/prepare'
m.cm_prepare
  distrib: 'precise'
  cache_dir: './cache'
, (err, status) ->
  console.log err, status
COFFEE
```

    export default header: 'Cloudera Manager Server Prepare', handler: (options) ->
      # options.cdh_version ?= '5.7.0'
      options.distrib ?= 'el6'
      options.services ?= ['cdh5', 'accumulo', 'sqoop-connectors', 'phoenix', 'kafka']
      # options.sources['cdh4'] ?= null
      options['cdh4'] ?= version: '4.7.1.47'
      options['cdh5'] ?= version: '5.7.0'
      options['accumulo'] ?= version: '1.6.0'
      options['sqoop-connectors'] ?= version: '1.5.9'
      options['phoenix'] ?= version: '1.2.0.774', baseurl: 'http://archive.cloudera.com/cloudera-labs/phoenix/parcels/'
      options['kafka'] ?= version: '1.1.0.23', baseurl: 'http://archive.cloudera.com/cloudera-labs/kafka/parcels/'
      for service in options.services then do (service) =>
        @call
          header: "Read Manifest #{service}"
          unless: options[service].sources
          shy: true
        , (_, callback) ->
          baseurl = options[service].baseurl or "https://archive.cloudera.com/#{service}/parcels/"
          request "#{baseurl}/#{options[service].version}/manifest.json", json: true, (err, req, data) =>
            return callback err if err
            filenames = data.parcels.filter (parcel) ->
              parcel.parcelName.endsWith "#{options.distrib}.parcel"
            if filenames.length is 0
              @log message: "Invalid distribution", level: 'WARN', module: '@rybajs/metal/cloudera-manager/server/prepare'
              return callback()
            options[service].sources = []
            options[service].sources.push "#{baseurl}/#{options[service].version}/#{filename.parcelName}" for filename in filenames
            callback()
        @call
          header: "Download #{service}"
        , ->
          @file.cache (
            if: source
            source: source
            cache_dir: options.cache_dir
          ) for source in options[service].sources or []

## Dependencies

    request = require 'request'
