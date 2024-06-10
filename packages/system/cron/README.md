
# Cron

Deploys crontab to a given user

## Configuration

* `purge` (boolean)   
   Should the module remove all pre existing crontabs before making sure provided ones are present
* `crontabs` (object)   
   K/V of arrays of crontab objects in the form `'user': [{when: "x x x x x", cmd: "foo bar"}]`

    export default (service) ->
      options = service.options

## Notes

Purging before re applying the rules is an easy choice but parsing and deleting individual rules does not seem to be a better option.

## TODO

- Validate crontabs

## Resources

*   [Crontab Guru](https://crontab.guru/)
*   [How to create a cron job using Bash automatically without the interactive editor?](https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor)
