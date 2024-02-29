# Header
Every source code file, verification file and script file shall have a short header, in form of comments, that provides the following information:
- License: Permissions of file usage
- Author: Original creator of the file
- Library: Identifies the place where the file belongs
- Description: A brief purpose of the file is a must. Further, detailed explanation is optional
# Naming Conventions
Naming conversions are required in order to be able to write consistent code, that is easier to understand once the reader is familiar with the conventions.

| Group         | Name                   | Prefix | Body      | Postfix | Example         | Description                                                                                                             |
| ------------- | ---------------------- | ------ | --------- | ------- | --------------- | ----------------------------------------------------------------------------------------------------------------------- |
| IO            | Input                  | i_     |           |         | i_clk           | Input of a module                                                                                                       |
| IO            | Output                 | o_     |           |         | o_vld           | Output of a module                                                                                                      |
| IO            | Inout                  | io_    |           |         | io_data         | Inout of a module                                                                                                       |
| IO            | Interface              | if_    |           |         | if_axi          | Can be also used inside module                                                                                          |
| Logic         | Register               | q_     |           |         | q_cmp           | Register output inside a module                                                                                         |
| Logic         | Combinational          | c_     |           |         | c_sum           | Uncertain or mixed signals shall also use this                                                                          |
| Logic         | Wire                   | w_     |           |         | w_grant         | Signal is directly connected to something with no logic in between                                                      |
| Complex Logic | Struct Type            | t_     |           |         | t_ext_data      | The name of the defined struct, not the declared signal                                                                 |
| Complex Logic | Instance               | inst_  |           |         | inst_input_fifo | Instantiated module                                                                                                     |
| Block         | Generate               | g_     |           |         | g_fifo          | Labels inside a generate block                                                                                          |
| Block         | Process                | p_     |           |         | p_delay         | Labels of an always block                                                                                               |
| Reset         |                        |        | rst       |         | i_rst           | Synhronous reset                                                                                                        |
| Reset         |                        |        | arst      |         | i_arst_n        | Asynchronous reset                                                                                                      |
| Clock         | Clock                  |        | clk       |         | i_clk           | Clock source                                                                                                            |
| Logic         | Active-low             |        |           | \_n     | i_arst_n        |                                                                                                                         |
| Handshake     | Valid                  |        | vld       |         |                 | Ready to send                                                                                                           |
| Handshake     | Ready                  |        | rdy       |         |                 | Ready to receive                                                                                                        |
| Constants     | Parameter / localparam |        | *CAPITAL* |         |                 | Parameters and localparams are considered as constants from the module's perspective. They shall be written in capital. |
# Comments
Comments should be used in the following cases:
- Separator / indetifier: Comments can be used to split up the file into multiple sections. These sections shall be identified in the comment
- Additional information: Provides further explanation that is not obvious