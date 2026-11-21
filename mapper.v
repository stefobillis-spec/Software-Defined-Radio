`timescale 1ns / 1ps


module mapper #(
    parameter WORD_WIDTH = 8,
    parameter CLK_FREQ = 50000000,
    parameter BITRATE = 1000000
 )(
    input wire clk,
    input wire reset,
    input wire [WORD_WIDTH-1:0] data_in,
    input wire data_vld,
    output reg [23:0] phase_out,
    output reg phase_vld,
    output reg [1:0] bits
    );
    
    
localparam integer CLKS_PER_SYMBOL = (2 * CLK_FREQ) / BITRATE;
localparam integer TIMER_WIDTH = (CLKS_PER_SYMBOL <= 1) ? 1 : $clog2(CLKS_PER_SYMBOL);
   
//reg [WORD_WIDTH-1:0] data_in_reg;
//reg [1:0] counter;

reg [WORD_WIDTH-1:0] shift_reg;
reg [1:0] symbol_count;
reg [TIMER_WIDTH-1:0] symbol_timer;
reg busy;
reg pattern_vld;
   
   
    
reg [1:0] bit_pattern;
//reg [23:0] phase;
reg [4:0] register_1;
reg [4:0] register_2;

reg vld_reg1;
reg vld_reg2;
reg vld_reg3;




always @(posedge clk) begin
    if (reset) begin
        vld_reg1 <= 0;
        vld_reg2 <= 0;
        vld_reg3 <= 0;
    end
    else begin
        vld_reg1 <= data_vld;
        vld_reg2 <= vld_reg1;
        vld_reg3 <= vld_reg2;
    end
end



always @(posedge clk) begin
    if (reset) begin
        shift_reg    <= 0;
        bit_pattern  <= 0;
        symbol_count <= 0;
        symbol_timer <= 0;
        busy         <= 0;
        pattern_vld  <= 0;
    end
    else begin
        pattern_vld <= 0;

        // Capture a new 8-bit word from UART
//        if (data_vld && !busy) begin
        if (vld_reg3 && !busy) begin
            shift_reg    <= data_in;
            symbol_count <= 0;
            symbol_timer <= 0;
            busy         <= 1;
        end

        // Process the four 2-bit symbols
        else if (busy) begin
            if (symbol_timer == CLKS_PER_SYMBOL - 1) begin

                // Extract the two most significant bits
                bit_pattern <= shift_reg[WORD_WIDTH-1 -: 2];

                // Shift remaining data toward MSB
                shift_reg <= shift_reg << 2;

                pattern_vld <= 1;

                symbol_timer <= 0;

                if (symbol_count == 3) begin
                    symbol_count <= 0;
                    busy <= 0;
                end
                else begin
                    symbol_count <= symbol_count + 1;
                end
            end
            else begin
                symbol_timer <= symbol_timer + 1;
            end
        end
    end
end
   
   




//always @(posedge(clk)) begin
//    if (reset == 1) begin
//        data_in_reg <= 0;
//    end
//    else begin
//        if (data_vld == 1) begin
//            data_in_reg <= data_in;
//        end
        
//        if (counter < WORD_WIDTH) begin
//            counter <= counter + 1;
//            bit_pattern <= data_in_reg[counter:counter-1];
//        end
//    end
//end



    
always @(posedge(clk)) begin
    if (reset == 1) begin
//        phase_out <= 0;
        phase_out <= 24'b111010000000000000000000;
//        phase <= 0;
//        bit_pattern <= 0;
//        phase <= 24'b111010000000000000000000;
    end
    else if (pattern_vld) begin
//        phase_out <= phase;
        bits <= bit_pattern;
        case (bit_pattern)
            2'b11: phase_out = 24'b000010000000000000000000; // 0.25
            2'b01: phase_out = 24'b000110000000000000000000; // 0.75
            2'b00: phase_out = 24'b111010000000000000000000; // -0.75
            2'b10: phase_out = 24'b111110000000000000000000; // -0.25
            default: phase_out = 24'b111010000000000000000000; // -0.75
        endcase
    end
end


always @(posedge(clk)) begin
    if (reset == 1) begin
        register_1 <= 0;
        register_2 <= 0;
        phase_vld <= 0;
    end
    else begin
        register_1 <= phase_out[23:19];
        register_2 <= register_1;
        if (register_1 != register_2) begin
            phase_vld <= 1;
        end 
        else begin
            phase_vld <= 0;
     end      
end
end

    
endmodule
