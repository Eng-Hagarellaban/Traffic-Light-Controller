module FSM_Traffic_Light_Controller(
    input wire        CLK_1HZ,
    input wire        reset,
    input wire        timer_done,
    input wire        ped_button,
    output reg [3:0]  timer_limit,
    output reg        timer_rst,
    output reg [11:0] leds 
);
//(State Encoding)
parameter   NS_GREEN         = 3'b000,
            NS_GREEN_Extend  = 3'b001,
            NS_YELLOW        = 3'b010,
            EW_GREEN         = 3'b011,
            EW_GREEN_Extend  = 3'b100,
            EW_YELLOW        = 3'b101;

reg [2:0] current_state, next_state;     
// State Register
always @(posedge CLK_1HZ or posedge reset) 
    begin
        if (reset)
        begin
            current_state <= NS_GREEN; 
        end
        else
        begin
            current_state <= next_state;
        end
    end  
//Next State Logic
always@(*)
begin
    current_state <= next_state;
    case(current_state)
    NS_GREEN : 
    begin
        if (ped_button)
        begin
            next_state <= NS_GREEN_Extend;
        end
        else if (timer_done)
        begin
            next_state <= NS_YELLOW;
        end
    end
    NS_GREEN_Extend :
    begin
        if (timer_done) 
        begin
        next_state <= NS_YELLOW;
        end
    end
    NS_YELLOW :
    begin
        if (timer_done) 
        begin
        next_state <= EW_GREEN;
        end
    end
    EW_GREEN:
    begin
        if (ped_button)
        begin
        next_state <= EW_GREEN_Extend;
        end
        else if (timer_done)
        begin
            next_state <= EW_YELLOW;
        end
    end
   EW_GREEN_Extend :
        begin
            if (timer_done)
                next_state = EW_YELLOW;
        end
        
        EW_YELLOW :
        begin
            if (timer_done)
                next_state = NS_GREEN; 
        end
        
        default: next_state = NS_GREEN;
    endcase
end

always @(*)
begin
    
    timer_limit = 4'd10;
    timer_rst   = 1'b0;
    leds        = 12'b0;

    case(current_state)
        NS_GREEN, NS_GREEN_Extend: begin
            timer_limit = (current_state == NS_GREEN_Extend) ? 4'd15 : 4'd10;
            timer_rst   = timer_done;
           
            leds = 12'b100_100_001_001;
        end

        NS_YELLOW: begin
            timer_limit = 4'd3;
            timer_rst   = timer_done;
            
            leds = 12'b100_100_010_010;
        end

        EW_GREEN, EW_GREEN_Extend: begin
            timer_limit = (current_state == EW_GREEN_Extend) ? 4'd15 : 4'd10;
            timer_rst   = timer_done;
           
            leds = 12'b001_001_100_100;
        end

        EW_YELLOW: begin
            timer_limit = 4'd3;
            timer_rst   = timer_done;
           
            leds = 12'b010_010_100_100;
        end
    endcase
end

endmodule