`timescale 1ns/1ps

`include "sys_defs.svh"

module testbench;

    // LAB3 TODO: there may or may not be errors in this testbench
    //            however, the errors are not in the general testbench functionality
    //            feel free to modify from here...

    // DUT I/O
    logic       clock;
    logic       reset;
    logic       valid;
    logic [3:0] num;
    logic [3:0] seq;
    logic       hit;
    logic [3:0] cnt, n_cnt;
    STATE       state, n_state;

    // Testbench variables
    logic [3:0] int_cnt; // Keeps track of # hits on input
    logic [3:0] hit_cnt; // Used to monitor hit output signal
    logic [3:0] seq_len;

    fsm_b dut(
        .clock,
        .reset,
        .valid,
        .num,
        .seq,
        .state,
        .cnt,
        .n_cnt,
        .hit
    );

    // LAB3 TODO: ...up to here

    // ---- DO NOT MODIFY PAST THIS POINT ----

    // CLOCK_PERIOD is defined on the commandline by the makefile
    always begin
        #(`CLOCK_PERIOD/2.0);
        clock = ~clock;
    end

    // ---- Start Testbench ----
    initial begin
        // setup monitor and reset signals
        $monitor("time: %3.0d vld: %b num: %2.0d seq: %2.0d cnt: %2.0d n_cnt: %2.0d state: %s n_state: %s hit: %b",
                 $time, valid, num, seq, cnt, n_cnt, state, n_state, hit);

        clock = 1'b0;
        reset = 1'b0;
        valid = 1'b0;
        num   = 4'h5;
        seq   = 4'h0;
        seq_len = 4'h0;
        int_cnt = 4'h0;
        hit_cnt = 4'h0;

        // Apply reset to DUT
        reset = 1'b1;
        @(negedge clock);
        reset = 1'b0;

        // Apply sequence with zero matches
        // then wait 11-15 cycles to start over (to allow for hit cycles)
        apply_sequence(4'd10, NO_MATCH);
        repeat (11) @(negedge clock);

        // Apply sequence with all matches
        apply_sequence(4'd10, MATCH);
        repeat (11) @(negedge clock);

        // Apply sequence with length 1 (no match)
        apply_sequence(4'd1, NO_MATCH);
        repeat (2) @(negedge clock);

        // Apply sequence with length 1 (match)
        apply_sequence(4'd1, MATCH);
        repeat (3) @(negedge clock);

        // Go through 5 rounds of random sequences
        repeat(5) begin
            seq_len = ($random % 4'd10) + 1; // num between 1-10
            apply_sequence(seq_len, RAND);
            repeat (11) @(negedge clock);
        end

        @(negedge clock);
        $display("@@@ Passed: SUCCESS! \n ");
        $finish;
    end

    // ---- Testbench functions ----

    // Block to monitor "hit" output
    always @(negedge clock) begin
        #1;
        // Check to see if hit is asserted when it shouldn't be
        if (hit && hit_cnt==0) begin
            $display("@@@ Incorrect: Hit asserted erroneously!");
            $finish;

        // Check to see if hit not asserted when it should be
        end else if (!hit && hit_cnt>0) begin
            $display("@@@ Incorrect: Hit not asserted but should be!");
            $finish;

        // Decrement counter
        end else if (hit && hit_cnt>0) begin
            hit_cnt = hit_cnt-4'h1;
        end
    end


    // Task to apply a sequence of numbers to the DUT
    task apply_sequence;
        input [3:0] length;
        input OVERRIDE override; // RAND:     use random inputs
                                 // MATCH:    force seq to match num
                                 // NO_MATCH: force seq to not match num
        begin
            int_cnt = 4'h0;
            valid   = 1'b1;
            repeat(length) begin
                @(negedge clock);
                case(override)
                    RAND:     seq = ($random % 'd16); // num between 0-15
                    MATCH:    seq = num;
                    NO_MATCH: seq = ~num;
                endcase
                if (seq == num)
                    int_cnt = int_cnt + 4'h1;
            end
            valid = 1'b0;
            // Initialize hit_cnt for hit output monitoring
            #2;
            hit_cnt = int_cnt;
        end
    endtask

endmodule
