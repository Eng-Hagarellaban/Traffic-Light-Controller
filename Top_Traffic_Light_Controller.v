module Top_Traffic_Light_Controller (
    input wire        CLK_100MHZ,   
    input wire        reset,        
    input wire        ped_button,   
    output wire [11:0] leds          
);

    wire        w_clk_1Hz;
    wire        w_timer_done;
    wire        w_timer_rst;
    wire [3:0]  w_timer_limit;

    Clock_DIvider_Traffic_Light_Controller u_clk_div (
        .CLK_IN   (CLK_100MHZ),
        .Rest     (reset),
        .CLK_1HZ  (w_clk_1Hz)
    );

    Timer_Traffic_Light_Controller u_timer (
        .CLK_1HZ     (w_clk_1Hz),
        .reset       (reset),
        .Timer_rst   (w_timer_rst),
        .timer_limit (w_timer_limit),
        .timer_done  (w_timer_done)
    );

    FSM_Traffic_Light_Controller u_fsm (
        .CLK_1HZ     (w_clk_1Hz),
        .reset       (reset),
        .timer_done  (w_timer_done),
        .ped_button  (ped_button),
        .timer_limit (w_timer_limit),
        .timer_rst   (w_timer_rst),
        .leds        (leds)
    );

endmodule