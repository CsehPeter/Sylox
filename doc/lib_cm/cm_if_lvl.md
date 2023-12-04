# Brief
Common level interface is used to represent the number of data entries inside a storage.
# Parameters
| Name     | Type | Default | Range | Description                                                         | Comment |
| -------- | ---- | ------- | ----- | ------------------------------------------------------------------- | ------- |
| CAPACITY | u32  | 0       | 0..   | The maximum number of data that can be represented by the interface |         |
# Ports
| Name    | Type              | Direction | Description                                                  |
| ------- | ----------------- | --------- | ------------------------------------------------------------ |
| lim     | logic             | mosi      | Limit, boundary of the represented range (E.g.: empty, full) |
| lvl     | logic \[CAPACITY] | mosi      | Level, represents how full or empty a storage is             |
| lvl_thr | logic \[CAPACITY] | miso      | Level threshold                                              |
| lvl_gte | logic             | mosi      | Level is Greater-Than-or-Equal to threshold                  |
# Modports
- Master: The module, that implements the interface, provides level information about it's storage
- Slave: The module, that implements the interface, received level information about a storage