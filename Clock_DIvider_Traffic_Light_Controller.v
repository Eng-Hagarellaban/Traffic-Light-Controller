module Clock_DIvider_Traffic_Light_Controller
(
    input wire CLK_IN,
    input wire Rest,
    output reg CLK_1HZ
);
reg [25:0] counter ; // 26 bit = log2(100MHz/2)
always@(posedge CLK_IN or posedge Rest)
begin
    if (Rest)
    begin
        counter <= 26'd0;
        CLK_1HZ <= 1'b0;
    end
    else
    begin
        if (counter == 26'd49_999_999)
        begin
            counter <= 26'd0;
            CLK_1HZ <= ~CLK_1HZ;
        end
        else
        begin
            counter <= counter +1;
        end
    end
end
endmodule