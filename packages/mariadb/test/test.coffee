
fs = require 'fs'
# Write default configuration
if not process.env['RYBA_TEST_MODULE'] and (
  not fs.existsSync("#{__dirname}/../test.js") and
  not fs.existsSync("#{__dirname}/../test.json") and
  not fs.existsSync("#{__dirname}/../test.coffee")
)
  config = fs.readFileSync "#{__dirname}/../test.sample.coffee"
  console.log('config:', config)
  fs.writeFileSync "#{__dirname}/../test.coffee", config
# Read configuration
config = require process.env['RYBA_TEST_MODULE'] or "../test.coffee"
# Export configuration
module.exports = config
