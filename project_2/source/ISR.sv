module ISR (
    input reset,
    input [63:0] value,
    input clock,
    output logic [31:0] result,
    output logic done
);

    logic [31:0] temp_result;
    logic [5:0] bit_position;  
    logic [63:0] square;       

    typedef enum logic [1:0] {IDLE, CALCULATE, DONE} state_t;
    state_t state;

    always_ff @(posedge clock) begin

        if (reset) begin
            result <= 0;
            temp_result <= 0;
            bit_position <= 31;
            state <= CALCULATE;
            done <= 0;
        end 
        else if (state == CALCULATE) begin
            temp_result[bit_position] = 1;
            square = temp_result * temp_result;

            if (square > value) begin
                temp_result[bit_position] = 0; 
            end

            if (bit_position == 0) begin
                result <= temp_result; 
                state <= DONE;
                done <= 1;
            end 
            else begin
                bit_position <= bit_position - 1;
            end
        end 
        else if (state == DONE) begin
            done <= 1;
        end
    end

endmodule
