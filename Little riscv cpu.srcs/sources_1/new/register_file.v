`timescale 1ns / 1ps
module register_file(
    input clk, input reset, 
    input [31:0] instr, output [31:0] a, output [31:0] b, 
    input [31:0] write_instr, input [31:0] current_pc, input [4:0] write_address, input [31:0] rd_value);
    
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    
    reg [31:0] register_set [0:31];
    reg [4:0] a_address = 0;
    reg [4:0] b_address = 0;
    
    wire [31:0] data = (write_instr[6:0] == 7'b1101111) ? (current_pc + 4) : rd_value;
    
    
    // read data
    always @(*)begin
        if(opcode == 7'b0110011
        || opcode == 7'b0100011
        || opcode == 7'b1100011)begin // R, S, B Type
            a_address = instr[19:15];
            b_address = instr[24:20];
        end
        else if(opcode == 7'b0010011
        || opcode == 7'b0000011)begin // I-Type
            a_address = instr[19:15];
            b_address = 0;
        end
        else begin // J-Type
            a_address = 0;
            b_address = 0;
        end
    end
    
    assign a = (write_address != 5'b0 && write_address == a_address) ? data : register_set[a_address];
    assign b = (write_address != 5'b0 && write_address == b_address) ? data : register_set[b_address];
    
    
    // write data or reset
    integer i;
    always @(posedge clk)begin
        register_set[0] <= 32'b0;
        if(reset == 0)begin
            for (i = 1; i < 32; i = i + 1) begin
                register_set[i] <= 32'b0;
            end
        end
        else if(write_address != 5'b0) register_set[write_address] <= data;
    end
endmodule