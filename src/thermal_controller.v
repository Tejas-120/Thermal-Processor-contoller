`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Thermal Process Controller
// ---------------------------------------------------------------------------
// A 4-state Moore FSM (IDLE -> NORMAL -> WARNING -> CRITICAL) that monitors
// an 8-bit temperature input and drives throttle / alert / shutdown outputs
// as thresholds are crossed.
//////////////////////////////////////////////////////////////////////////////
module thermal_controller(
    input clk,
    input rst,
    input [7:0] temp_in,
    output reg throttle,
    output reg alert,
    output reg shutdown
);

parameter NORMAL_T   = 8'd50;
parameter WARNING_T  = 8'd70;
parameter CRITICAL_T = 8'd85;

parameter IDLE     = 2'b00;
parameter NORMAL   = 2'b01;
parameter WARNING  = 2'b10;
parameter CRITICAL = 2'b11;

reg [1:0] state;
reg [1:0] next_state;

//////////////////////////////////////////////////
// STATE REGISTER
//////////////////////////////////////////////////
always @(posedge clk or posedge rst)
begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

//////////////////////////////////////////////////
// NEXT STATE LOGIC
//////////////////////////////////////////////////
always @(*)
begin
    case (state)
        IDLE:
            if (temp_in >= NORMAL_T)
                next_state = NORMAL;
            else
                next_state = IDLE;

        NORMAL:
            if (temp_in >= WARNING_T)
                next_state = WARNING;
            else if (temp_in < NORMAL_T)
                next_state = IDLE;
            else
                next_state = NORMAL;

        WARNING:
            if (temp_in >= CRITICAL_T)
                next_state = CRITICAL;
            else if (temp_in < WARNING_T)
                next_state = NORMAL;
            else
                next_state = WARNING;

        CRITICAL:
            if (temp_in < WARNING_T)
                next_state = NORMAL;
            else
                next_state = CRITICAL;

        default:
            next_state = IDLE;
    endcase
end

//////////////////////////////////////////////////
// OUTPUT LOGIC
//////////////////////////////////////////////////
always @(*)
begin
    throttle = 0;
    alert    = 0;
    shutdown = 0;

    case (state)
        WARNING: begin
            throttle = 1;
            alert    = 1;
        end
        CRITICAL: begin
            throttle = 1;
            alert    = 1;
            shutdown = 1;
        end
    endcase
end

endmodule
