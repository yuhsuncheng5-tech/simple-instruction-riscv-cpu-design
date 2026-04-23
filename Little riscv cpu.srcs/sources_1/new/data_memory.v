`timescale 1ns / 1ps

// default data is unknown
module data_memory( 
    input clk, input reset,
    input [31:0] instr, input [31:0] target_address,
    input [31:0] store_data, output reg [31:0] load_data);
    
    reg [31:0] data_mem [0:255];
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    
    // write data or reset
    always @(posedge clk)begin
        if(opcode == 7'b0100011 && funct3 == 3'b010)begin // SW
            data_mem[target_address[9:2]] <= store_data;
        end
    end 
    
    always @(*) begin // LW
        if(opcode == 7'b0000011 && funct3 == 3'b010)begin
            load_data = data_mem[target_address[9:2]];
        end
        else load_data = 32'b0;
    end
endmodule
