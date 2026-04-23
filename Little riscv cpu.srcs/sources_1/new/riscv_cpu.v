`timescale 1ns / 1ps  
module riscv_cpu(
    input clk,
    input rst,
    output [31:0] current_pc,
    input [31:0] instruction_in
);
     
 // Control signal and data   
wire stall = ({IDEX_instr[6:0], IDEX_instr[14:12]} == 10'b0000011010 && IDEX_rd != 5'b0 && (IFID_rs1 == IDEX_rd || IFID_rs2 == IDEX_rd)) ? 1 : 0;
wire [31:0] current_pc;
wire [31:0] reg_a_data;
wire [31:0] reg_b_data;
wire [31:0] data_mem_load_data;
reg [31:0] alu_data1 = 32'b0;
reg [31:0] alu_data2 = 32'b0;
wire [31:0] alu_output;
wire flush;


// pipeline register data
reg [31:0] IFID_pc = 32'b0;
reg [31:0] IFID_instr = 32'b0;
wire [4:0] IFID_rs1 = IFID_instr[19:15];
wire [4:0] IFID_rs2 = IFID_instr[24:20];
wire [4:0] IFID_rd  = (IFID_instr[6:0] == 7'b0100011 || IFID_instr[6:0] == 7'b1100011) ? 5'b0 : IFID_instr[11:7]; // rd = 0 if SW or BEQ

reg [31:0] IDEX_pc = 32'b0;
reg [31:0] IDEX_instr = 32'b0;
reg [31:0] IDEX_data1 = 32'b0;
reg [31:0] IDEX_data2 = 32'b0;
wire [4:0] IDEX_rs1 = IDEX_instr[19:15];
wire [4:0] IDEX_rs2 = IDEX_instr[24:20];
wire [4:0] IDEX_rd  = (IDEX_instr[6:0] == 7'b0100011 || IDEX_instr[6:0] == 7'b1100011) ? 5'b0 : IDEX_instr[11:7]; // rd = 0 if SW or BEQ

reg [31:0] EXMEM_pc = 32'b0;
reg [31:0] EXMEM_instr = 32'b0;
reg [31:0] EXMEM_data1 = 32'b0;
reg [31:0] EXMEM_data2 = 32'b0;
reg [31:0] EXMEM_data3 = 32'b0; // alu output
wire [4:0] EXMEM_rs1 = EXMEM_instr[19:15];
wire [4:0] EXMEM_rs2 = EXMEM_instr[24:20];
wire [4:0] EXMEM_rd  = (EXMEM_instr[6:0] == 7'b0100011 || EXMEM_instr[6:0] == 7'b1100011) ? 5'b0 : EXMEM_instr[11:7]; // rd = 0 if SW or BEQ

reg [31:0] MEMWB_pc = 32'b0;
reg [31:0] MEMWB_instr = 32'b0;
reg [31:0] MEMWB_data1 = 32'b0;
reg [31:0] MEMWB_data2 = 32'b0;
reg [31:0] MEMWB_data3 = 32'b0;
wire [4:0] MEMWB_rs1 = MEMWB_instr[19:15];
wire [4:0] MEMWB_rs2 = MEMWB_instr[24:20];
wire [4:0] MEMWB_rd  = (MEMWB_instr[6:0] == 7'b0100011 || MEMWB_instr[6:0] == 7'b1100011) ? 5'b0 : MEMWB_instr[11:7]; // rd = 0 if SW or BEQ


// Instances
pc my_pc(
    clk, 
    rst, 
    stall,
    flush, 
    alu_output, 
    current_pc
);
    
register_file reg_file(
    clk, 
    rst, 
    IFID_instr,
    reg_a_data, 
    reg_b_data,
    MEMWB_instr,
    MEMWB_pc, 
    MEMWB_rd, 
    MEMWB_data3
);

data_memory data_mem( 
    clk, 
    rst,
    EXMEM_instr, 
    EXMEM_data3,
    EXMEM_data2, 
    data_mem_load_data
);    

alu ALU( 
    IDEX_instr, 
    alu_data1, 
    alu_data2, 
    IDEX_pc,
    alu_output, 
    flush
);


// forwarding
always@(*)begin
    if(EXMEM_rd != 5'b0 && IDEX_rs1 == EXMEM_rd) alu_data1 = EXMEM_data3; 
    else if(MEMWB_rd != 0 && IDEX_rs1 == MEMWB_rd) alu_data1 = MEMWB_data3;
    else alu_data1 = IDEX_data1;
    
    if(EXMEM_rd != 5'b0 && IDEX_rs2 == EXMEM_rd) alu_data2 = EXMEM_data3; 
    else if(MEMWB_rd != 0 && IDEX_rs2 == MEMWB_rd) alu_data2 = MEMWB_data3;
    else alu_data2 = IDEX_data2;
end


// IF/ID
always @(posedge clk)begin
    IFID_pc <= (!rst || flush) ? 32'b0 : ((stall) ? IFID_pc : current_pc);
    IFID_instr <= (!rst || flush) ? 32'b0 : ((stall) ? IFID_instr : instruction_in);
end


// ID/EX
always @(posedge clk)begin
    IDEX_pc <= (!rst || flush || stall) ? 32'b0 : IFID_pc;
    IDEX_instr <= (!rst || flush || stall) ? 32'b0 : IFID_instr;
    IDEX_data1 <= (!rst || flush || stall) ? 32'b0 : reg_a_data;
    IDEX_data2 <= (!rst || flush || stall) ? 32'b0 : reg_b_data;
end


// EX/MEM note that there is no need to flush
always @(posedge clk)begin
    EXMEM_pc <= (!rst) ? 32'b0 : IDEX_pc;
    EXMEM_instr <= (!rst) ? 32'b0 : IDEX_instr;
    EXMEM_data1 <= (!rst) ? 32'b0 : alu_data1;
    EXMEM_data2 <= (!rst) ? 32'b0 : alu_data2;
    EXMEM_data3 <= (!rst)          ? 32'b0 : alu_output; // alu output
end


// MEM/WB
always @(posedge clk)begin
    MEMWB_pc <= (!rst) ? 32'b0 : EXMEM_pc;
    MEMWB_instr <= (!rst) ? 32'b0 : EXMEM_instr;
    MEMWB_data1 <= (!rst) ? 32'b0 : EXMEM_data1;
    MEMWB_data2 <= (!rst) ? 32'b0 : EXMEM_data2;
    
    if(!rst) MEMWB_data3 <= 32'b0;
    else if(EXMEM_instr[6:0] == 7'b0000011) MEMWB_data3 <= data_mem_load_data;
    else MEMWB_data3 <= EXMEM_data3;
end

endmodule