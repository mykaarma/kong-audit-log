local cjson = require "cjson"
local ngx = require "ngx"

local function fetchAuditLogs(reqEntity, reqEntityId, reqOperation, from, to)
  local t = setmetatable({}, cjson.array_mt)
  for log_entry, err in kong.db.audit_log:each(100) do
    if ((reqEntity == nil or log_entry.entity == reqEntity) and (reqOperation == nil or log_entry.operation == reqOperation) and (reqEntityId==nil or log_entry.entity_id == reqEntityId) and (log_entry.performed_at>=from) and (log_entry.performed_at<=to)) then
      if log_entry.old_data and log_entry.old_data.password then
        log_entry.old_data.password = "***"
      end
      if log_entry.new_data and log_entry.new_data.password then
        log_entry.new_data.password = "***"
      end
      t[#t+1] = log_entry
      t[#t].performed_at = os.date("%Y-%m-%dT%H:%M:%S", t[#t].performed_at) .. "+00:00"
     end
  end
  return cjson.encode(t)
end
  
local function setFromAndTo(from, to)
  local format = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)(.)(%d+):(%d+)"
  local err
   if from ~= nil then
     local from_year, from_month, from_day, from_hour, from_min, from_sec, from_sign, from_tz_hour, from_tz_min
     from_year, from_month, from_day, from_hour, from_min, from_sec, from_sign, from_tz_hour, from_tz_min = from:match(format)
     if from_sign == '+' then
       from = os.time({year=from_year, month=from_month, day=from_day, hour=from_hour, min=from_min, sec=from_sec}) - (from_tz_hour*60*60 + from_tz_min*60)
     elseif from_sign == '-' then
       from = os.time({year=from_year, month=from_month, day=from_day, hour=from_hour, min=from_min, sec=from_sec}) + (from_tz_hour*60*60 + from_tz_min*60)
     else
       from = os.time({year=from_year, month=from_month, day=from_day, hour=from_hour, min=from_min, sec=from_sec})
     end
   end
   if to ~= nil then
     local to_year, to_month, to_day, to_hour, to_min, to_sec, to_sign, to_tz_hour, to_tz_min
     to_year, to_month, to_day, to_hour, to_min, to_sec, to_sign, to_tz_hour, to_tz_min = to:match(format)
     if to_sign == '+' then
       to = os.time({year=to_year, month=to_month, day=to_day, hour=to_hour, min=to_min, sec=to_sec}) - (to_tz_hour*60*60 + to_tz_min*60)
     elseif to_sign == '-' then
       to = os.time({year=to_year, month=to_month, day=to_day, hour=to_hour, min=to_min, sec=to_sec}) + (to_tz_hour*60*60 + to_tz_min*60)
     else
       to = os.time({year=to_year, month=to_month, day=to_day, hour=to_hour, min=to_min, sec=to_sec})
     end
   end
   if from == nil and to == nil then
     to = os.time()
     from = to - 30*24*60*60
   elseif from == nil then
     from = to - 30*24*60*60
   elseif to == nil then
     to = from + 30*24*60*60
   end
   if from>to then
     err = {}
     err.status_code = 400
     err.message = "To cannot be greater than from"
   elseif to-from>30*24*60*60 then
     err = {}
     err.status_code = 400
     err.message = "The difference between from and to should not be more than 30 days"
   end
   return from, to, err
end

return {
  ["/audit-log"] = {
        GET = function()
           local args = ngx.req.get_uri_args()
           local operation = args.operation
           local from = args.from
           local to = args.to
           local err
           from, to, err = setFromAndTo(from, to)
           if err then
             return kong.response.exit(400, cjson.encode(err))
           end
           local result = fetchAuditLogs(_, _, operation, from, to)
           return kong.response.exit(200, result)
        end,
  },
  ["/audit-log/:entity"] = {
        GET = function(self)
           local args = ngx.req.get_uri_args()
           local operation = args.operation
           local from = args.from
           local to = args.to
           from, to, err = setFromAndTo(from, to)
           if err then
             return kong.response.exit(400, cjson.encode(err))
           end
           local result = fetchAuditLogs(self.params.entity, _, operation, from, to)
           return kong.response.exit(200, result)
        end,
  },
   ["/audit-log/:entity/:entity_id"] = {
        GET = function(self)
           local args = ngx.req.get_uri_args()
           local operation = args.operation
           local from = args.from
           local to = args.to
           from, to, err = setFromAndTo(from, to)
           if err then
             return kong.response.exit(400, cjson.encode(err))
           end
           local result = fetchAuditLogs(self.params.entity, self.params.entity_id, operation, from, to)
           return kong.response.exit(200, result)
        end,
  },
}
