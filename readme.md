# Project
The goal of the project is to create general SystemVerilog library code that can be used in different HDL designs.

- Currently the target is to make a stream type interconnect module (e.g. AXIS interconnect)
- The project does not contain proper verification (UVM or formal), only simple simulation, so be aware of bugs
# Environment
- HDL language: SystemVerilog
- IDE: AMD Vivado 2023.1
- Version Control: git
- Documentation:
	- Markdown (.md) files: Created with Obsidian (https://obsidian.md/)
	- Drawings (.drawio) files: Created with drawio (https://www.drawio.com/)
# Project Structure
- status.md: Track the status of project modules

- doc: Documentation of both source and verification code. Include all .md files and all drawings
- guide: Templates that should help the development
- hdl: Hardware Description Language (HDL), source code of Systemverilog (.sv) modules, interfaces, packages.
- script: Auxiliary script code that helps the development
- verif: Code for testing the source codes in the *hdl* folder