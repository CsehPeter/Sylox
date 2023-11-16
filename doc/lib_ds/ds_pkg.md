# Types
## Flow-Control
*t_fc* is used to describe the flow-control properties of a data steam interface.

| Value  | Name           | Description                                                                      |
| ------ | -------------- | -------------------------------------------------------------------------------- |
| FC_BI  | Bidirectional  | Each block has to accept the transaction (handshake)                             |
| FC_UNI | Unidirectional | Only the transmitter has to initiate the transaction, the receiver can't decline |
| FC_NO  | Uncontrolled   | There is no flow control, all data in every clock cycle is valid                 |

## FIFO Architecture
*t_fifo_arch* is used to describe the internal structure of a FIFO.

| Value         | Description                                                                                      |
| ------------- | ------------------------------------------------------------------------------------------------ |
| FIFO_ARCH_RAM | Both the write and read uses addresses to select a value in the memory                           |
| FIFO_ARCH_SHR | The FIFO's read order is handled with a shifting mechanism. While the write order is addressable |
