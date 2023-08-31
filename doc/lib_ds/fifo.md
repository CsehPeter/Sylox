# Brief

# Parameters
| name     | type | default | range | description                                    |
| -------- | ---- | ------- | ----- | ---------------------------------------------- |
| width    | u32  | 8       | 1..   | Data width of the FIFO                         |
| capacity | u32  | 2       | 1..   | Number of words that can be stored in the FIFO |
|          |      |         |       |                                                |
# Ports
| name      | type   | reset value | description |
| --------- | ------ | ----------- | ----------- |
| i_clk     | bit    |             |             |
| i_rst     | bit    |             |             |
| if_wr_ds  | if_str |             |             |
| if_wr_lvl | if_lvl |             |             |
| if_rd_ds  | if_str |             |             |
| if_rd_lvl | if_lvl |             |             |


