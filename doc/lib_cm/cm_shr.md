# Brief
Simple shift register for delaying data.

![alt text](draw/svg/cm_shr_bd_brief.drawio.svg)
# Parameters
| Name     | Type        | Default       | Range | Description                                    | Comment                      |
| -------- | ----------- | ------------- | ----- | ---------------------------------------------- | ---------------------------- |
| LEN | u32         | 2             | 0..   | Number of register stages | Can be 0 for bypass                             |
| DTYPE    | type        | logic [7 : 0] | -     | Type of a single data word                       |                              |
| RST_MODE     | t_shr_rst | SHR_RST_FIRST | -     | Reset mode                              | [[cm_pkg#Shift Register Reset]] |
# Ports
| Name      | Type          | Direction | Description                 |
| --------- | ------------- | --------- | --------------------------- |
| i_clk     | logic         | in        | Clock source                |
| i_rst     | logic         | in        | Reset                       |
| i_data     | DTYPE     | in       | Input data |
| o_data | DTYPE | out       | Output data       |
# Requirements
| Category | ID  | Severity | Statement                                                 | Comment                   |
| -------- | --- | -------- | --------------------------------------------------------- | ------------------------- |
| Reset    | RST | Shall    | On active reset, the proper register(s) shall be set to 0 | Depends on the *RST_MODE* |
| Operation         | OP    | Shall         | *o_data* shall be equivalent of *i_data* delayed by *LEN* clock cycles                                                           |                           |

## Operation Waveform
### Reset First
![alt text](draw/svg/cm_shr_wf_rst_first.drawio.svg)
### Reset All
![alt text](draw/svg/cm_shr_wf_rst_all.drawio.svg)