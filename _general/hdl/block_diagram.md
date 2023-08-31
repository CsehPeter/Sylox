A universal block diagram format is needed for describing digital logic

It shall have customizable graphic symbols

It shall contain settings for:
    - blocks
        -- class name
        -- object name
        -- types:
            --- cells (primitives)
            --- classes
        -- outline type (multiple hierarchical levels)
        -- fill color (gradient)
    - ports
        -- name
        -- type:
            --- combinational
            --- latch
            --- FF
        -- I/O

    - connections
        -- source
        -- destination
        -- junction of connections
            --- not connected
            --- connected
            --- concatenated
            --- split
        -- signal width
        -- connection type (multiple hierarchical level)
