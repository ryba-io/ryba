
# Dependencies
import each from 'each'

# Crontab Install
export default
  header: 'Cron'
  handler: ({options}) ->
    # Deploy crontabs
    {purge} = options
    @each options.crontabs, ({options}) ->
      user = options.key
      crontabs = options.value
      # Eventually purge previous crontab
      @system.execute
        header: "Delete all existing crontabs for user #{user}"
        if: purge
        user: user
        cmd: "crontab -u #{user} -r"
        code: [0, 1]
      , (err, {stdout, stderr}) ->
        throw err if err and not /^no crontab for/.test stderr
      # Apply crontabs
      for crontab in crontabs
        @tools.cron.add
          cmd: crontab.cmd
          when: crontab.when
          user: user
