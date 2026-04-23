`timescale 1ns / 1ps
module pc( input clk, input reset, input stall , 
    input flush, input [31:0] jump_address, 
    output reg [31:0] current_pc);
    
    always @(posedge clk)begin
        if(reset == 0) current_pc <= 0;
        else if(stall) current_pc <= current_pc;
        else if (flush) current_pc <= jump_address; // flush serves as a jump and branch signal
        else current_pc <= current_pc + 4;
    end
endmodule