
`include "sys_defs.svh"

// LAB5 TODO: functionality check list
// [ ] update elements on positive clock edge
// [ ] if enable and command is WRITE, store data to write_idx
// [ ] validate that write_idx is not too large
// [ ] if enable and command is READ, set read_idx to first idx of matching data
// [ ] set hit to high if found, or low if not
// [ ] pass the testbench
// [ ] pass testbench in synthesis (don't worry about clock period)

module CAM #(parameter SIZE=8) (
    input         clock, reset,
    input         enable,
    input COMMAND command,
    input [31:0]  data,
    input [$clog2(SIZE)-1:0] write_idx,

    output logic [$clog2(SIZE)-1:0] read_idx,
    output logic hit
);

    // LAB5 TODO: Fill in design here
    // note: must work for all sizes, including non powers of two



endmodule
