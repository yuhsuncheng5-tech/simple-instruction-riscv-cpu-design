`timescale 1ns / 1ps 
module alu( 
    input [31:0] instr, 
    input [31:0] a, input [31:0] b, 
    input [31:0] current_pc, output reg [31:0] c, 
    output reg flush
);
    // Predict branch not taken
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
  
    always @(*) begin
        if(instr == 0) begin // NOP
            c = 0;
            flush = 0;
        end
        else if(opcode == 7'b0110011) begin // R-Type
            flush = 0;
            case({funct3, funct7})
                10'b000_0000000: c = a + b; // ADD
                10'b000_0100000: c = a - b; // SUB
                10'b111_0000000: c = a & b; // AND
                10'b110_0000000: c = a | b; // OR
                10'b100_0000000: c = a ^ b; // XOR
                default: c = 0;
            endcase
        end
        else if(opcode == 7'b0010011) begin // ADDI and NOT
            flush = 0;
            case(funct3)
                3'b000: c = a + {{20{instr[31]}}, instr[31:20]}; // ADDI
                3'b100: c = a ^ {{20{instr[31]}}, instr[31:20]}; // XORI
                default: c = 0;
            endcase
        end
        else if(opcode == 7'b1100011 && funct3 == 3'b000) begin // B-Type specifically designed for BEQ
            c = current_pc + {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            flush = (a == b) ? 1 : 0;
        end
        else if(opcode == 7'b1101111) begin // J-Type specifically designed for JAL
            c = current_pc + {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            flush = 1;
        end
        else if(opcode == 7'b0000011)begin // LW
            c = a + {{20{instr[31]}}, instr[31:20]};
            flush = 0;
        end
        else if(opcode == 7'b0100011)begin // SW
            c = a + {{20{instr[31]}}, instr[31:25], instr[11:7]};
            flush = 0;
        end
        else begin
            c = 0;
            flush = 0;
        end
    end    
endmodule