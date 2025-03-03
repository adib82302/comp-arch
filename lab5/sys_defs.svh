`ifndef __SYS_DEFS_VH__
`define __SYS_DEFS_VH__

`ifdef SYNTH
// rename the CAM module to CAM_svsim
// this is a synthesized instance of the CAM with size CAM_SIZE
`define INSTANCE(mod) ``mod``_svsim
`else
// if not in synthesis, can just instantiate like normal
`define INSTANCE(mod) mod
`endif

typedef enum logic {READ, WRITE} COMMAND;

`endif // __SYS_DEFS_VH__
