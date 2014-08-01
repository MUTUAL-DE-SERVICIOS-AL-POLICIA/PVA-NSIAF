root = exports ? this

class Utils
  # Convert single quotes to hiphen
  @singleQuotesToHiphen: (string) ->
    value = string.val().toString().trim()
    value.replace(/\'/g, '-')

root.Utils = Utils
