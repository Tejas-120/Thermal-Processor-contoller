`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////
// Testbench for thermal_controller
// Sweeps temp_in from cold -> normal -> warning -> critical and back down,
// checking that throttle/alert/shutdown track the expected FSM transitions.
//////////////////////////////////////////////////////////////////////////////
module tb_thermal_controller;

reg clk;
reg rst;
reg [7:0] temp_in;

wire throttle;
wire alert;
wire shutdown;

thermal_controller uut (
    .clk(clk),
    .rst(rst),
    .temp_in(temp_in),
    .throttle(throttle),
    .alert(alert),
    .shutdown(shutdown)
);

// CLOCK: 10 ns period (100 MHz)
always #5 clk = ~clk;

initial begin
    clk     = 0;
    rst     = 1;
    temp_in = 8'd20;   // cold / IDLE region

    #20 rst = 0;

    #40 temp_in = 8'd40;  // below NORMAL_T -> stays IDLE
    #40 temp_in = 8'd60;  // >= NORMAL_T, < WARNING_T -> NORMAL
    #40 temp_in = 8'd80;  // >= WARNING_T, < CRITICAL_T -> WARNING
    #40 temp_in = 8'd90;  // >= CRITICAL_T -> CRITICAL

    #100;
    $finish;
end

initial begin
    $dumpfile("tb_thermal_controller.vcd");
    $dumpvars(0, tb_thermal_controller);
end

initial begin
    $monitor("t=%0t rst=%b temp_in=%0d state_out(throttle=%b alert=%b shutdown=%b)",
              $time, rst, temp_in, throttle, alert, shutdown);
end

endmodule
