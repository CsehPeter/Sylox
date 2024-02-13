# Libraries
- lib_sys: System library. Contains generic types, constants, functions, macros that can be used by any other library in the design.
- lib_cm: Common modules library. Contains basic modules that could be used by other libraries
- lib_ds: Data Stream library. Contains modules that use one or more data stream interfaces
  # Dependency
  
  ```mermaid
	flowchart BT
		lib_cm --> lib_sys
		lib_ds --> lib_sys
		lib_ds --> lib_cm
	```