# Know-how

# Types

# Functions

## is_stage_reg
**Brief**: Determines whether the current stage of a pipeline should be registered or not. [[#Know-how#Register Balancing]]

| Parameter | Name                   | Type | Description                                                                |
| --------- | ---------------------- | ---- | -------------------------------------------------------------------------- |
| ts        | Total Stage Count      | u32  | Total number of stages inside a pipeline                                   |
| rs        | Registered Stage Count | u32  | Required number of registered stages                                       |
| cs        | Current Stage Index    | u32  | Current stage which needs to be determined as registered or not registered |

