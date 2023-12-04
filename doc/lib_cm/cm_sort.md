# Brief
Provides a pipelined, parallel sorting logic.

![alt text](draw/cm_sort_top.drawio.svg)
# Parameters
| Name    | Type | Default | Range | Description                                               | Comment                                   |
| ------- | ---- | ------- | ----- | --------------------------------------------------------- | ----------------------------------------- |
| DCNT    | u32  | 4       | 2..   | Number of individual data signals that needs to be sorted |                                           |
| DWIDTH  | u32  | 8       | 1..   | Data Width                                                |                                           |
| REG_CNT | u32  | 1       | 0..   | Number of registered stages                               | The maximum is the total number of stages |
# Ports
| Name   | Type        | Direction | Description                |
| ------ | ----------- | --------- | -------------------------- |
| i_clk  | logic       | in        | Clock source               |
| i_rst  | logic       | in        | Reset                      |
| i_vld  | logic       | in        | Input data valid           |
| i_data | logic\[]\[] | in        | Input data array           |
| o_vld  | logic       | out       | Output data valid          |
| o_data | logic\[]\[] | out       | Output (sorted) data array |
# Requirements
| Category  | ID     | Severity | Statement                                                                                                              | Comment |
| --------- | ------ | -------- | ---------------------------------------------------------------------------------------------------------------------- | ------- |
| Reset     | RST    | Shall    | On reset, all register stages shall be cleared                                                                         |         |
| Interface | IF_IN  | Shall    | When *i_vld* is HIGH the array of inputs shall be sorted                                                               |         |
| Interface | IF_OUT | Shall    | *o_vld* shall indicate a valid, sorted array                                                                           |         |
| Operation | OP_DIR | Shall    | The module shall use ascending sort. Lowest number of the input array shall go to the lowest index of the output array |         |
| Latency   | LAT    | Shall    |                                                                                                                        |         |
# Architecture
TODO