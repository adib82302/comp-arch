`timescale 1ns/1ps

`include "sys_defs.svh"

module testbench;

    logic clock, reset, enable;
    logic [31:0] data;
    COMMAND command;

    logic [$clog2(`CAM_SIZE)-1:0] write_idx, read_idx;
    logic hit;

    // INSTANCE is from the sys_defs.svh file
    // it renames the module if SYNTH is defined in
    // order to rename the module to CAM_svsim
    `INSTANCE(CAM) #(.SIZE(`CAM_SIZE)) cam_test(
        .clock, .reset, .enable, .command, .write_idx, .read_idx, .data, .hit
    );


    // CLOCK_PERIOD is defined on the commandline by the makefile
    always begin
        #(`CLOCK_PERIOD/2.0);
        clock = ~clock;
    end


    task exit_on_error;
        begin
            $display("@@@Failed at time %d", $time);
            $finish;
        end
    endtask


    initial begin
        $monitor("Command: %s, enable: %b, data: %h, write_idx: %h, read_idx: %h, hit: %b",
                 command.name, enable, data, write_idx, read_idx, hit);

        clock     = 0;
        write_idx = 0;
        enable    = 0;
        command   = READ;
        data      = 0;

        // Initial Reset
        reset = 1;
        @(negedge clock)
        reset = 0;

        // Check that all elements start invalid
        @(negedge clock);
        assert(!hit) else exit_on_error;

        // Initialize the memory
        command = WRITE;
        enable = 1;
        for(int i=0; i<`CAM_SIZE; i++) begin
            write_idx = i;
            data = $random;
            @(negedge clock);
        end

        // Overwrite memory locations with new data
        for(int i=0; i<(2**$clog2(`CAM_SIZE)); i++) begin
            write_idx = i;
            data = i;
            @(negedge clock);
        end

        // Read back data
        command = READ;
        for(int i=0; i<`CAM_SIZE; i++) begin
            data = i;
            @(negedge clock);
            assert(hit && read_idx == i) else exit_on_error;
        end

        // Check the size of read data
        data = `CAM_SIZE;
        @(negedge clock);
        assert(!hit) else exit_on_error;

        // And again with random values
        command   = WRITE;
        data      = $random;
        write_idx = 0;
        @(negedge clock);
        repeat (5) begin
            write_idx = $random;
            @(negedge clock);
        end

        command = READ;
        @(negedge clock);
        assert(read_idx == 0) else exit_on_error;

        $display("@@@Passed");
        $finish;
    end

endmodule
