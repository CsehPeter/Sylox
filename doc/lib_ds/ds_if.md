# Brief
Provides data stream interface with parametrized data type.
# Parameters
| Name  | Type | Default       | Range | Description  | Comment                 |
| ----- | ---- | ------------- | ----- | ------------ | ----------------------- |
| DTYPE | type | logic [7 : 0] |       | Data type    |                         |
| FC    | t_fc | FC_BI         |       | Flow-Control | [[ds_pkg#Flow-Control]] |
# Ports
| Name | Type      | Direction | Description                  |
| ---- | --------- | --------- | ---------------------------- |
| vld  | logic     | mosi      | Transmitter is ready to send |
| rdy  | logic     | miso      | Receiver is ready to receive |
| xfer | logic     | out       | A single transmission event  |
| data | data_type | mosi      | Transferred data             |
# Flow-Control
| FC     | Signals   | Description                                           |
| ------ | --------- | ----------------------------------------------------- |
| FC_BI  | *vld* & *rdy* | Both signals are required for a transmission          |
| FC_UNI | *vld*       | Only the transmitter has to initiate the transmission |
| FC_NO  | -         | No flow control                                       |
# Modports
- Master: In master mode, the module that implements the interface, is the transmitter
- Slave: in slave mode, the module that implements the interface, is the receiver