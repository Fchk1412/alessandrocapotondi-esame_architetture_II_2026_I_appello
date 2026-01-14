module smart_gate_controller (
    input  clk_i,
    input  reset_ni,

    input  car_i,
    input  pay_ok_i,
    input  clear_i,
    input  cnt_reset_i,

    output reg gate_open_o,
    output reg gate_close_o,
    output reg red_o,
    output reg yellow_o,
    output reg green_o,
    output reg [7:0] car_count_o
);

    reg [3:0] state, next_state;

    //states

    parameter WAIT        = 4'd0;
    parameter PRE_OPEN_1  = 4'd1;
    parameter PRE_OPEN_2  = 4'd2;
    parameter WAIT_CLEAR  = 4'd3;
    parameter OPEN_PULSE  = 4'd4;
    parameter PASS_1      = 4'd5;
    parameter PASS_2      = 4'd6;
    parameter PASS_3      = 4'd7;
    parameter PRE_CLOSE   = 4'd8;   
    parameter CLOSE       = 4'd9;   
    // state register
    always @(negedge clk_i or negedge reset_ni) begin
        if (!reset_ni)
            state <= WAIT;
        else
            state <= next_state;
    end

    // next state logic
    always @(state or car_i or pay_ok_i or clear_i) begin
        case (state)

            WAIT: begin
                if (car_i && pay_ok_i)
                    next_state = PRE_OPEN_1;
                else
                    next_state = WAIT;
            end

            PRE_OPEN_1:   next_state = PRE_OPEN_2;
            PRE_OPEN_2:   next_state = WAIT_CLEAR;

            WAIT_CLEAR: begin
                if (clear_i)
                    next_state = OPEN_PULSE;
                else
                    next_state = WAIT_CLEAR;
            end

            OPEN_PULSE:   next_state = PASS_1;
            PASS_1:       next_state = PASS_2;
            PASS_2:       next_state = PASS_3;
            PASS_3:       next_state = PRE_CLOSE;
            PRE_CLOSE:    next_state = CLOSE;
            CLOSE:        next_state = WAIT;

            default:      next_state = WAIT;
        endcase
    end

    //output logic 
    always @(state) begin
        red_o        = 1'b0;
        yellow_o     = 1'b0;
        green_o      = 1'b0;
        gate_open_o  = 1'b0;
        gate_close_o = 1'b0;

        case (state)

            WAIT: begin
                red_o = 1'b1;
            end

            PRE_OPEN_1,
            PRE_OPEN_2,
            WAIT_CLEAR: begin
                yellow_o = 1'b1;
            end

            OPEN_PULSE: begin
                green_o     = 1'b1;
                gate_open_o = 1'b1;
            end

            PASS_1,
            PASS_2,
            PASS_3: begin
                green_o = 1'b1;
            end

            PRE_CLOSE: begin
                yellow_o = 1'b1;
            end

            CLOSE: begin
                red_o        = 1'b1;
                gate_close_o = 1'b1;
            end

            default: begin
                red_o = 1'b1;
            end
        endcase
    end

    //counter
    always @(negedge clk_i or negedge reset_ni) begin
        if (!reset_ni)
            car_count_o <= 8'd0;
        else if (cnt_reset_i)
            car_count_o <= 8'd0;
        else if (state == OPEN_PULSE) begin
            if (car_count_o != 8'd255)
                car_count_o <= car_count_o + 8'd1;
        end
    end

endmodule
