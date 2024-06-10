
export default (service) ->
  options = service.options
  # Pip packages
  options.packages ?= {}
