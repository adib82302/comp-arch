`include "sys_defs.svh"

module fsm_b (
    input       clock,
    input       reset,
    input       valid,
    input [3:0] num,
    input [3:0] seq,
    output STATE       state,
    output STATE       n_state,
    output logic [3:0] cnt,
    output logic [3:0] n_cnt,
    output logic       hit
);

    logic cnt_inc, cnt_dec;

    assign cnt_inc = (state == WATCH) && (seq == num);
    assign cnt_dec = (state == ASSERT) && (cnt > 0);
    
    assign n_cnt = cnt_inc ? cnt + 4'h1 :
                   cnt_dec ? cnt - 4'h1 : cnt;

    always_comb begin
        case (state)
            WAIT:
                if (valid) 
                    n_state = WATCH;
                else       
                    n_state = WAIT;

            WATCH:
                if (!valid) 
                    n_state = (cnt > 0) ? ASSERT : WAIT;
                else        
                    n_state = WATCH;

            ASSERT:
                if (cnt > 0) 
                    n_state = ASSERT;  
                else          
                    n_state = WAIT;  

            default: 
                n_state = WAIT;
        endcase
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= WAIT;
            cnt   <= 4'h0;
            hit   <= 1'b0;  // Reset hit
        end else begin
            state <= n_state;
            cnt   <= n_cnt;
            
            // ✅ FIX: Ensure hit stays high while cnt > 0 in ASSERT state
            if (n_state == ASSERT) begin
                hit <= 1'b1;
            end else begin
                hit <= 1'b0;
            end
        end
    end

endmodule
