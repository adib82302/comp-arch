`timescale 1ns/1ps

module testbench;

    // LAB3 TODO: there may or may not be errors in this testbench
    //            however, the errors are not in the general testbench functionality
    //            feel free to modify from here...

    // Internal Variables
    logic correct;
    logic [1:0] f1_state;

    // Module Inputs/Outputs
    logic clock;
    logic reset;
    logic in;
    logic out;

    fsm_a f1(
        .clock(clock),
        .reset(reset),
        .in(in),
        .out(out),
        .state_out(f1_state)
    );

    // LAB3 TODO: ...up to here

    // ---- DO NOT MODIFY PAST THIS POINT ----

    // CLOCK_PERIOD is defined on the commandline by the makefile
    always begin
        #(`CLOCK_PERIOD/2.0);
        clock = ~clock;
    end

    // ---- Test bench functions ----
    task exit_on_error;
        begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ Time:%4.0f clock:%b reset:%h  state=%b  in:%b out:%b correct:%b",
                     $time, clock, reset, f1_state, in, out, correct);
            $display("ENDING TESTBENCH : ERROR !");
            $finish;
        end
    endtask

    always_ff @(negedge clock) begin
        if( !correct ) begin // CORRECT CASE
            exit_on_error();
        end
    end

    // check
    function EXPECTED_OUT;
        input in;
        begin
            EXPECTED_OUT = (f1_state[1] && f1_state[0]);
        end
    endfunction

    task CHECK_STATE;
        input [1:0] tb_state;
        begin
            if( tb_state === f1_state ) correct =  1;
            else correct = 0;
        end
    endtask

    // ---- Start Testbench ----
    initial begin
        $display("STARTING TESTBENCH!\n");

        // INIT STATE
        correct = 1;
        clock   = 0;
        reset   = 1;
        in      = 0;

        // TRANSITION TESTS
        reset = 1;
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        reset = 0;
        in = 0;
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        in = 1;
        CHECK_STATE( 2'b00 );
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        CHECK_STATE( 2'b01 );
        in = 1;
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        CHECK_STATE( 2'b01 );
        in = 0;
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        CHECK_STATE( 2'b10 );
        in = 1;
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        CHECK_STATE( 2'b11 );
        in = 0;
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        CHECK_STATE( 2'b10 );
        in = 0;
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        CHECK_STATE( 2'b00 );

        //RANDOM TESTS
        $display("reset=%b  state=%b  in=%b  out=%b  correct=%b", reset, f1_state, in, out, correct);
        @(negedge clock);
        reset = 0;
        for (int i=0; i < 400; i=i+1) begin
            in = $random;
            if (i % 10) reset = 0;
            else reset = 1;
            #1 //Short delay to evaulate
            $display("  i=%d  reset=%b  state=%b  in=%b  out=%b  correct=%b", i, reset, f1_state, in, out, correct);
            correct = (reset) ? ( out == 2'b00 ) : ( out == EXPECTED_OUT(in) ) ;
            @(negedge clock);
        end

        //SUCCESSFULLY END TESTBENCH
        $display("@@@ Passed");
        $display("ENDING TESTBENCH : SUCCESS !\n");
        $finish;

    end

endmodule
