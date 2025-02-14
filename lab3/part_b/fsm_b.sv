
// LAB3 TODO: there may or may not be bugs in this module.
// You need to get this module to work according to the
// testbench by fixing any bugs you find.
// Although the testbench/makefile might not be perfect either...

`include "sys_defs.svh"

module fsm_b (
    input       clock,
    input       reset,
    input       valid,
    input [3:0] num,
    input [3:0] seq,

    // debug signals for the testbench
    output STATE       state,
    output STATE       n_state,
    output logic [3:0] cnt,
    output logic [3:0] n_cnt,
    output logic       hit
);

    logic cnt_inc, cnt_dec;

    // Control/output logic
    assign cnt_inc = (n_state == WATCH) && (seq==num);
    assign cnt_dec = (n_state == ASSERT);
    assign n_cnt   = cnt_inc ? cnt + 4'h1 :
                     cnt_dec ? cnt - 4'h1 : cnt;

    assign hit = (state == ASSERT);

    // Next-state logic
    always_comb begin
        case (state)
            WAIT:
                if (valid) n_state = WATCH;
                else       n_state = WAIT;

            WATCH:
                if (!valid) n_state = (n_cnt==0) ? WAIT : ASSERT;
                else        n_state = WATCH;

            ASSERT:
                // check >1, because if we decrement to 0 we'll assert
                // hit one time too many
                if (cnt>4'h1) n_state = ASSERT;
                else          n_state = WAIT;

            default: n_state = WAIT;
        endcase
    end

    always_ff @(posedge clock) begin
        if (reset) begin
            state <= WAIT;
            cnt   <= 4'h0;
        end else begin
            state <= n_state;
            cnt   <= n_cnt;
        end
    end

endmodule
