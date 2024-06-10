
each = require 'each'

export default
  header: 'Pip'
  handler: ({options}) ->
    @service
      header: "Install python3-pip package"
      name: "python3-pip"
    @system.execute
      header: "Upgrade pip"
      cmd: "pip3 install --upgrade pip"
    for pckg in options.packages
      @system.execute
        header: "Install #{pckg} pip"
        cmd: "pip3 install #{pckg}"
