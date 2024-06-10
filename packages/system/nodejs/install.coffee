

import install_n from './actions/install_n'

export default header: 'Node.js Install', handler: (options) ->
  @call
    header: 'Node.js with N'
    if: options.method is 'n'
  , install_n
  # NPM configuration
  # Write the "~/.npmrc" file for each user defined by the "masson/core/users" 
  # module.
  @call header: 'NPM Configuration', ->
    @file.ini (
      if: !!user.config
      target: "#{user.target}"
      content: user.config
      merge: user.merge
      uid: user.uid
      gid: user.gid
    ) for _, user of options.users
