local typedefs = require "kong.db.schema.typedefs"

return {
  audit_log = {
    name = "audit_log",
    primary_key = { "id" },
    fields = {
      { id = { type = "integer" }, },
      { entity = { type = "string" }, },
      { entity_name = { type = "string" }, },
      { entity_id = { type = "string" }, },
      { operation = { type = "string" }, },
      { old_data = { type = "string" } },
      { new_data = { type = "string" } },
      { performed_at = typedefs.auto_timestamp_s },
      { action_by = { type = "string" } },
    },
  },
}
