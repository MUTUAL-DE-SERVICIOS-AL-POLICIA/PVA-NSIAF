root = exports ? this

class Utils
  # Convert single quotes to hyphen
  @singleQuotesToHyphen: (string) ->
    value = string.toString().trim()
    value.replace(/\'/g, '-')

root.Utils = Utils
