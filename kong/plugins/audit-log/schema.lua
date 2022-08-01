local typedefs = require "kong.db.schema.typedefs"

return {
  name = "audit-log",
  fields = {
    { config = {
        type = "record",
        fields = {},
    }, },
  },
}
