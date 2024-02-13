
| Component       | File       | Done  | Design  | Verification | Documentation | Comment                     |
| --------------- | ---------- |:-----:| ------- | ------------ | ------------- | --------------------------- |
| Shift Register  | cm_shr.sv  | ==1== | DONE    | DONE*     | DONE          |  |
| FIFO            | ds_fifo.sv | ==1== | DONE    | DONE*        | DONE          |      |
| Sorting Network | cm_sort.sv | ==0== | DONE    | DONE         | TODO          |                             |
| Arbiter         | cm_arbiter | ==0== | ONGOING | TODO         | TODO          |                             |
\*Only the waveform is inspected, no proper test is done. Expect bugs.
# Guide
The project is build-up of libraries, which contains modules. Each module's status shall be managed.

Keywords to describe the phase of a module task:

| Keyword | Description                                                                                                |
| -------:| ---------------------------------------------------------------------------------------------------------- |
|    TODO | The item is not started yet                                                                                |
| ONGOING | The item is started, it is in progress and has no known blocking issue                                     |
|    TEST | The item requires tests to be passed                                                                       |
|    DONE | The item is finished and performs correctly                                                                |
|   STUCK | Work on the item can't be continued, because of a blocking issue. E.g. a fundamental issue in an algorithm |
|   ERROR | The item is currently not working due to a failed test                                                     |

## Example flows
1. 
```mermaid
	flowchart LR
		TODO --> ONGOING
		ONGOING --> DONE
	
		style TODO stroke-width:2px,stroke:#FEE231
		style ONGOING stroke-width:2px,stroke:#C2CD4B
		style DONE stroke-width:2px,stroke:#4AA77C
```
2. 
```mermaid
	flowchart LR
		TODO --> ONGOING
		ONGOING --> TEST
		TEST --> DONE
	
		style TODO stroke-width:2px,stroke:#FEE231
		style ONGOING stroke-width:2px,stroke:#C2CD4B
		style TEST stroke-width:2px,stroke:#84BA63
		style DONE stroke-width:2px,stroke:#4AA77C
```
3. 
```mermaid
	flowchart LR
		TODO --> ONGOING
		ONGOING --> TEST
		TEST --> DONE
		TEST --> ERROR
		ERROR --> ONGOING
	
		style TODO stroke-width:2px,stroke:#FEE231
		style ONGOING stroke-width:2px,stroke:#C2CD4B
		style TEST stroke-width:2px,stroke:#84BA63
		style DONE stroke-width:2px,stroke:#4AA77C
		style ERROR stroke-width:2px,stroke:#E76F51
```
