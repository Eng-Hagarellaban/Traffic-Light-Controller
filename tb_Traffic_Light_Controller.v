`timescale 1ns/1ps

module tb_Top_Traffic_Light_Controller;

    reg         CLK_100MHZ;
    reg         reset;
    reg         ped_button;
    wire [11:0] leds;

    // ---------------------------------------------------------------
    // DUT
    // ---------------------------------------------------------------
    Top_Traffic_Light_Controller DUT (
        .CLK_100MHZ (CLK_100MHZ),
        .reset      (reset),
        .ped_button (ped_button),
        .leds       (leds)
    );

    // 100 MHz clock -> 10 ns period
    initial CLK_100MHZ = 0;
    always #5 CLK_100MHZ = ~CLK_100MHZ;

    // ---------------------------------------------------------------
    // Helper: turn the 3-bit state code into a readable name
    // ---------------------------------------------------------------
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

    task pulse_1hz;
        begin
            force DUT.w_clk_1Hz = 1'b1;
            #2;
            force DUT.w_clk_1Hz = 1'b0;
            #2;
            release DUT.w_clk_1Hz;
        end
    endtask

    wire [15*8:0] w_state_name = state_name(DUT.u_fsm.current_state);

    integer i;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_Top_Traffic_Light_Controller);

        // ---- Reset ----
        reset      = 1;
        ped_button = 0;
        repeat (5) @(posedge CLK_100MHZ);
        reset = 0;

        $display(" time(ns) |   state       | timer_limit | timer_done | leds");
        $monitor("%0t | %-13s |     %0d      |     %b      | %b",
                  $time, w_state_name,
                  DUT.w_timer_limit, DUT.w_timer_done, leds);

        // ---- Let it run in NS_GREEN, no button press ----
        // NS_GREEN timer_limit = 10 seconds
        for (i = 0; i < 12; i = i + 1) begin
            pulse_1hz;
        end

        // ---- After NS_YELLOW (3s) we should be entering EW_GREEN ----
        for (i = 0; i < 5; i = i + 1) begin
            pulse_1hz;
        end

        // ---- Press pedestrian button while in EW_GREEN ----
        ped_button = 1;
        @(posedge CLK_100MHZ);
        ped_button = 0;

        // Should extend EW_GREEN to 15s instead of going straight to yellow
        for (i = 0; i < 20; i = i + 1) begin
            pulse_1hz;
        end

        // ---- Run a couple more full cycles with no button press ----
        for (i = 0; i < 40; i = i + 1) begin
            pulse_1hz;
        end

        // ---- Assert reset mid-operation, must return to NS_GREEN ----
        reset = 1;
        @(posedge CLK_100MHZ);
        reset = 0;

        for (i = 0; i < 8; i = i + 1) begin
            pulse_1hz;
        end

        $display("Simulation finished.");
        $finish;
    end

endmodule