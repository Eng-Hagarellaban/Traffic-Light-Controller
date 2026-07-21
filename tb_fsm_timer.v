`timescale 1ns/1ps
// -------------------------------------------------------------------
// Focused testbench: Timer + FSM only (bypasses the 100MHz->1Hz
// clock divider and drives CLK_1HZ directly with a fast simulated
// clock). This is the fastest way to check the traffic-light logic
// itself without waiting on real 50,000,000-cycle dividing.
// -------------------------------------------------------------------
module tb_FSM_Timer;
    reg clk = 0, reset, ped_button;
    wire timer_done, timer_rst;
    wire [3:0] timer_limit;
    wire [11:0] leds;

    always #10 clk = ~clk; // period 20ns stands in for one CLK_1HZ tick

    Timer_Traffic_Light_Controller u_timer (
        .CLK_1HZ     (clk),
        .reset       (reset),
        .Timer_rst   (timer_rst),
        .timer_limit (timer_limit),
        .timer_done  (timer_done)
    );

    FSM_Traffic_Light_Controller u_fsm (
        .CLK_1HZ     (clk),
        .reset       (reset),
        .timer_done  (timer_done),
        .ped_button  (ped_button),
        .timer_limit (timer_limit),
        .timer_rst   (timer_rst),
        .leds        (leds)
    );

    function [15*8:0] state_name;
        input [2:0] state;
        begin
            case (state)
                3'b000: state_name = "NS_GREEN";
                3'b001: state_name = "NS_GREEN_EXT";
                3'b010: state_name = "NS_YELLOW";
                3'b011: state_name = "EW_GREEN";
                3'b100: state_name = "EW_GREEN_EXT";
                3'b101: state_name = "EW_YELLOW";
                default: state_name = "UNKNOWN";
            endcase
        end
    endfunction

    integer i;

    initial begin
        $dumpfile("tb_fsm_timer.vcd");
        $dumpvars(0, tb_FSM_Timer);

        reset = 1; ped_button = 0;
        repeat (2) @(posedge clk);
        reset = 0;

        $display(" time(ns) |   state       | timer_limit | timer_done | leds");

        // Run several full state cycles with no button press
        for (i = 0; i < 60; i = i + 1) begin
            @(posedge clk);
            $display("%8t | %-13s |     %0d      |     %b      | %b",
                       $time, state_name(u_fsm.current_state),
                       timer_limit, timer_done, leds);
        end

        // Press the pedestrian button while sitting in NS_GREEN
        reset = 1; @(posedge clk); reset = 0;
        for (i = 0; i < 5; i = i + 1) @(posedge clk);
        ped_button = 1; @(posedge clk); ped_button = 0;
        for (i = 0; i < 20; i = i + 1) begin
            @(posedge clk);
            $display("%8t | %-13s |     %0d      |     %b      | %b",
                       $time, state_name(u_fsm.current_state),
                       timer_limit, timer_done, leds);
        end

        $display("Simulation finished.");
        $finish;
    end
endmodule