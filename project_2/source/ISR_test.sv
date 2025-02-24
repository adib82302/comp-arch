`timescale 1ns/1ps

module ISR_test;

    logic reset;
    logic [63:0] value;
    logic clock;
    logic [31:0] result;
    logic done;

    ISR dut (
        .reset(reset),
        .value(value),
        .clock(clock),
        .result(result),
        .done(done)
    );

    always #5 begin 
        clock = ~clock; 
    end

    task wait_until_done;
        int timeout = 1000; 
        begin
            while (!done && timeout > 0) begin
                #10;
                timeout--;
            end
            if (timeout == 0) begin
                $finish;
            end
        end
    endtask

    initial begin
        $display("Starting ISR Test...");

        clock = 0;
        reset = 1;
        #10 reset = 0;
        
        // ISR(24) =  4
        value = 24;
        wait_until_done;
        if (result == 4) $display("@@@ Passed: ISR(24) = 4");
        else $display("@@@ Incorrect: ISR(24) = %d", result);

        // ISR(1001) = 31
        reset = 1; #10 reset = 0;
        value = 1001;
        wait_until_done;
        if (result == 31) $display("@@@ Passed: ISR(1001) = 31");
        else $display("@@@ Incorrect: ISR(1001) = %d", result);

        // ISR(65536) = 256
        reset = 1; #10 reset = 0;
        value = 65536;
        wait_until_done;
        if (result == 256) $display("@@@ Passed: ISR(65536) = 256");
        else $display("@@@ Incorrect: ISR(65536) = %d", result);

        // ISR(0) = 0
        reset = 1; #10 reset = 0;
        value = 0;
        wait_until_done;
        if (result == 0) $display("@@@ Passed: ISR(0) = 0");
        else $display("@@@ Incorrect: ISR(0) = %d", result);

        //ISR(1) =   1
        reset = 1; #10 reset = 0;
        value = 1;
        wait_until_done;
        if (result == 1) $display("@@@ Passed: ISR(1) = 1");
        else $display("@@@ Incorrect: ISR(1) = %d", result);

        // Randomized Test Cases
        for (int i = 0; i < 10; i++) begin
            reset = 1; #10 reset = 0;
            value = $random; 
            wait_until_done;
            
            if (result == $floor($sqrt($itor(value)))) 
                $display("@@@ Passed: ISR(%d) = %d", value, result);
            else
                $display("@@@ Incorrect: ISR(%d) = %d", value, result);
        end

        $display("ISR Test Completed.");
        $finish;
    endmake 

endmodule


