# Brief

# Parameters
| name         | type   | default       | range | description |
| ------------ | ------ | ------------- | ----- | ----------- |
| flow_control | t_flow | bidirectional | enum  |             |
| data_type    | type   | \[7 : 0]      |       |             |
# Ports
| name | type      | reset value | description |
| ---- | --------- | ----------- | ----------- |
| vld  | bit       | 1'b0        |             |
| rdy  | bit       | 1'b0        |             |
| hs   | bit       | 1'b0        |             |
| data | data_type | '0          |             |
# Modports
- Master
- Slave