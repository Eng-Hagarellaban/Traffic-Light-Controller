module Timer_Traffic_Light_Controller(
    input wire CLK_1HZ,
    input wire reset,
    input wire Timer_rst,
    input wire [3:0] timer_limit,
    output reg timer_done
);
reg [3:0] counter;
always@(posedge CLK_1HZ or posedge reset )
begin
    if (reset )
    begin
        counter <= 4'b0;
        timer_done <= 1'b0;
    end
    else if (Timer_rst)
    begin
        counter <= 4'b0;
        timer_done <= 1'b0;
    end
    else
    begin
        if (counter >= timer_limit-1)
        begin
            timer_done <= 1'b1;
            counter <= counter;
        end
        else
        begin
            counter <= counter + 1;
            timer_done <= 1'b0;
        end
    end
end
endmodule

