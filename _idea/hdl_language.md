# 1. Table of Contents
Contents
...
# 2. General
Name: Marble / Granite
Brief: Object-oriented HDL language
## 2.1. Problems with Verilog / SystemVerilog:
- Can't get information from instantiated module (no backward parameter): Separate Initialization and Logic tool phases
- No inheritance: Inheritance should be the instantiation of the super class, and all data / methods are accessible as the child
- Can't access internal signals of a module, only if it is in the port list:
	- All internal signals should be able to read
       - Special construct, mutation should allow to modify a module's logic
- Safety implementation: needs to be added to every module
	- Needs to be able to search for specific criterias inside a module's objects
       - Needs to be able to get the driver of a signal
       - Needs to be able to apply modifications to the founds objects
# 3. Comments
Single line comments    : # "comment"
Block comments          : #* "comment" *#
# 4. Data
## 4.1. Variable & Signal Declaration
Syntax:
- "var_name" : "type"
- "var_name" = "init_val"
- "var_name" : "type" = "init_val"
If the type is not declared, it is assumed by the compiler
## 4.2. Data Types
Built-in types:
- bit
- u8, u16, u32, u64
- i8, i16, i32, i64...
- f32, f64
- str (string)

Logic
    wire, comb, reg, latch
## 4.3. Integer Numbers

Default number type: unsigned 32-bit integer in decimal format
syntax: `[bit_count][signedness][radix][value]`
- 1b1     : unsigned binary "1"
- 2sb10   : signed binary "10"
- 3o6     : unsigned octal "6"
- 8sxAF   : signed hexadecimal "AF"
- 0d134   : unsigned decimal "134", represented in clog2(134) bits

\[bit count] = 0: the number of bits is the least amount which can represent the given value
    (it might be unneccessary to add the '0')

## 4.4. Aggregate Data Types

...
# 5. Operators
## 5.1. Bitwise

- Unary:
    - ~"val"   : Bitwise NOT
    - &"val"   : Bitreduction AND operator
    - |"val"   : Bitreduction OR operator
    - ^"val"   : Bitreduction XOR operator

- Binary:
    - "val_0" & "val_1" : Bitwise AND
    - "val_0" | "val_1" : Bitwise OR
    - "val_0" ^ "val_1" : Bitwise OR

## 5.2. Arithmetic

- "val_0" + "val_1"     : Sum
- "val"++               : Increment
- "val_0" - "val_1"     : Subtract
- "val"--               : Decrement
- "var_0" * "val_1"     : Multiply
- "val_0" / "val_1"     : Divide
- "val_0" % "val_1"     : Modulo
- "val_0" ** "val_1"    : Exponential

## 5.3. Assignment

## 5.4. Comparation

- "val_0" == "val_1"    : Equal
- "val_0" != "val_1"    : Not qqual
- "val_0" > "val_1"     : Greater than
- "val_0" < "val_1"     : Less than
- "val_0" >= "val_1"    : Greater than or equal to
- "val_0" <= "val_1"    : Less than or equal to

## 5.5. Logical

- not "val"             : NOT
- "val_0" and "val_1"   : AND
- "val_0" or "val_1"    : OR
- "val_0" xor "val_1"   : XOR

## 5.6. Parenthesis & Brackets

## 5.7. Member

# 6. Control Flow

## 6.1. Branching

if
else
elif
case
comp_case

continue
break

## 6.2. Loop

for
while
# 7. Classes & Objects

- Scope

- Inheritance
    - super    : parent class

    - parent   : parent object
    - children : instantiated objects

- Magic functions
    - __init__()
    - __decl__()
    - __intf__()

    - __str__()
    - __cmp__()    : LT, LTE, EQ, GTE, GT

# 8. Built-in Functions

- type("val")               : Get type
- cmp("val_0", "val_1")     : Compare 2 values, output shall be in [LT, EQ, GT]
- range()                   :

## 8.1. Bit Manipulation
- cat                               : Concatenation
- shift("val", "dir", "shift_val")  : Shift
- rotate("val", "dir")              : Rotate

- shift left, shift right, rotate left, rotate right...

## 8.2. Size
- bits()    : Number of bits in a variable (or value)
- size()    : Number of units in a variable (or value)
- width()   : Size of the last dimension of a variable (or value)

## 8.3. Casting
- shape("val")              : Shape of a multi-dimensional tensor (or value)
- reshape("val", shape)     : Reshape tensor to new format
- bit(), u8(), ... str()    : cast to built-in type
- cast("val", type)         : cast to the target type

## 8.4. File Operations
- open("file", "operation type")
- close()
- seek()
- read()
- write()
- ... same as Python3

## 8.5. Mathematical

- log2      : log2
- clog2     : ceil(log2("val"))

# 9. Rules

- Rule : constraints and general behaviours
    -- scope: regex for block
    -- name: regex for name
    -- type: list of which objects to apply
    -- priority: higher priority should override the lower priority on conflicting rules

# 10. Design Workflow
Steps:
    1. Build configuration (build.toml) shall be specified
        1.a. The build configuration file shall contain whether the project is an application or a
        library project. An application has to have a top module, while the library does not have one

        1.b. Dependecies shall be specified
    2. Identifying the top module(s)
    3. [optional] Applying default parameters to the top module(s)
    4. Build module graph: top module __init__ and then submodules
    5. 

# 11. Libraries

- Programming
    -- regex
    -- math
    -- random
    -- time             : Date & time
    -- complex
    -- formater         : File format, object converter. JSON, CSV... etc

- Hardware
    -- floating point   : Arithmetic for floating point numbers
    -- fix point        : Arithmetic for fix point numbers
    -- sort             : Bitonis sort, highest, lowest

- Verification
    -- uvm
    -- formal

# 12. Keywords

import
as
from

class
def

if
else
elif
case

type
is

not
and
or
xor

true
false
none















####################################################################################################
## Optimize
####################################################################################################

It should be possible to determine optimization points in the design, and the compiler should be able to iteratively increase the optimization factor in case a certain path fails.

Process:
    - Design with optimization points
    - Design compile
    - Compilation fails due to implementation error (e.g. timing error)
    - Compiler shall increase the _opt_time_ parameter of the failing module instance and recompile that module instance

- Each class (module) should be able to access a hidden _opt parameter that is set by the compiler tool
- The designer should be able to read the parameter, but not write it (since it is technology dependent)
- The designer should be able to set the valid range of the _opt_ parameter for each type   (or the compiler should be able to tell)
- Opt types (all u32): _opt.timing, _opt.area, _opt.power

####################################################################################################
## IDE
####################################################################################################

Drawings : All drawing should be editable, code - draw convert in both direction
    - hierarchy - block diagram
    - fsm - fsm diagram
    - waveform description - waveform
    - class - UML diagrams

Code-time information:
    - Syntax error
    - Class resource estimation: using a standard cell library (or FPGA library), estimate cell count and register count, FSM count, instance count...
    - Class hierarchy relation error
    - [signedness] and [type] in number shall be a different color than [bit count] and [value]






####################################################################################################
## Example
####################################################################################################

```

class Adder:
    def __init__(data_width: u32):
        declare()
        interface()


    def __declare__():
        clk : Clock
        rst : Reset
        op_a : bit[data_width]
        op_b : bit[data_width]
        y : bit[data_width]

    def __interface__():
        inputs.append(clk)
        inputs.append(rst)
        inputs.append(op_a)
        inputs.append(op_b)
        outputs.append(y)

    def __logic__():
        add()
        output()

    def add():
        y = op_a + op_b





class Handshake:
    def __init__(mode):
        valid : bit
        ready : bit

        case(mode):
            "Master":
                outputs.append(valid)
                inputs.append(ready)
            "Slave":
                inputs.append(valid)
                outputs.append(ready)
        hs = valid & ready


class HandshakeBuffer:
    def __init__(data_width: u32, capacity: u32):
        din_hs : Handshake("Slave")
        din : bit[data_width]
        dout_hs : Handshake("Master")
        dout : bit[data_width]

        wc : bit[log2(capacity + 1)]

        inputs.append(din)
        io.append([in_hs, out_hs])
        outputs.append(dout)

    def __logic__():
        level()
        buffer()

    def level():

    def buffer():




class ClassName:
    def __init__(parameters):
        initialize()

    def __interface__(mode):
        set_ports(mode)

    def __logic__():
```