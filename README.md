# Audit-Log Plugin

This plugin tracks the changes in the Kong database and logs them in a table named audit-log.

## Installation

**Using Luarocks:**<br/>
The plugin can be installed by using the following command:<br/>
`luarocks install audit-log`

**Using source:**<br/>
`git clone https://github.com/mykaarma/kong-audit-log`<br/>
`cd kong-audit-log`<br/>
`luarocks make`<br/>

Also run the following command after installing the plugin:<br/>
`kong migrations up`<br/>

Then, add the plugin to the `plugins` key in `kong.conf` file.<br/>
`plugins=audit-log`


## Working

This plugin is mainly made up of SQL functions and triggers. The triggers are set to track changes in the *consumers*, *basicauth_credentials* and *plugins* tables. Only changes in rate-limits are logged from the `plugins` table.<br/>

**NOTE:** The plugin creates SQL triggers as soon as the `kong migrations up` command is executed so it need not be enabled explicitly.

## Log format

The changes are logged in the following format:

| Field | Description |
| ---   | ---         |
| entity | It is the entity. It can be either *consumer* or *basicauth_credentials* or *plugin*. |
| entity_name | It is the name of the entity. For eg- the name of the consumer. |
| entity_id | It is the id of the entity. |
| operation | It is the operation, i.e. either *created*, *updated* or *deleted*. |
| old_data | The data before performing the operation. It is stored in JSON format. |
| new_data | The data after performing the operation. It is stored in JSON format. |
| performed_at | The timestamp at which the operation is performed. |
| action_by | The user who performed the operation. It is stored in *user@ip* format. |


## Endpoint

The audit-logs are exposed using the following endpoints:
- `/audit-log` : It displays all the logs of the last 30 days.
- `/audit-log/{entity}` : It displays all the logs belonging to that particular entity. Here, the entity can be either *consumer* or *basicauth_credentials* or *plugin*.
- `/audit-log/{entity}/{entity_id}` : It displays all the logs belonging to that particular entity with the provided entity_id;

Also, the following parameters can be provided in the endpoint:
- `operation`: The operation performed, i.e. either *created*, *deleted* or *updated*. 
- `from`: The from timestamp. Provide time in this format: `(YYYY)-(MM)-(DD)T(hh):(mm):(ss)%2b(hh):(mm)` or `(YYYY)-(MM)-(DD)T(hh):(mm):(ss)%2d(hh)`. Here, `%2b` corresponds to `+` and `%2d` corresponds to `-`.
- `to`: The to timestamp. It's format is same as that of from.
