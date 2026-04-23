`timescale 1ns / 1ps
module top (
    input wire clk, // clk
    input wire btn0    // button0
);

    // Step 1: when button press (btn0=1) -> CPU run (rst=0)
    reg btn0_sync_1 = 1'b0;
    reg btn0_sync_2 = 1'b0;
    wire cpu_rst_n; // Active-low reset

    always @(posedge clk) begin
        btn0_sync_1 <= btn0;
        btn0_sync_2 <= btn0_sync_1;
    end

    // when btn0 = 1, rst  = 0;
    assign cpu_rst_n = ~btn0_sync_2; 


    // Step 2: get mem data to bram_array
    wire [31:0] pc_wire;
    wire [31:0] inst_wire;
    reg [31:0] bram_array [0:255]; // instruction_memory

    // ==========================================
    // THE FIX: Initialize memory and use absolute path
    // ==========================================
    integer i;
    initial begin
        // 1. Initialize all 256 memory slots to 0 to prevent 'X' values
        for (i = 0; i < 256; i = i + 1) begin
            bram_array[i] = 32'b0;
        end
        
        // 2. Load the program using the absolute Windows path
        $readmemh("C:/Deacon/Verilog/Little riscv cpu/Little riscv cpu.srcs/sources_1/new/program.mem", bram_array);
    end
    // ==========================================
    
    // Assign instruction data to inst_wire
    assign inst_wire = bram_array[pc_wire >> 2];


    // Step 3: create cpu object
    riscv_cpu my_cpu (
        .clk           (clk),      // 接上晶片的 12 MHz 心跳
        .rst           (cpu_rst_n),  // 接上按鈕控制的 wake-up 信號
        .current_pc        (pc_wire),    // CPU 告訴 BRAM 要讀哪裡
        .instruction_in(inst_wire)   // BRAM 將讀出的指令送回 CPU
    );


    // ========================================================
    // (可選進階) ILA 驗證：如果你想親眼看看有沒有「喚醒」成功
    // 1. 先 Run Synthesis
    // 2. Open Synthesized Design
    // 3. 點 Tools -> Set Up Debug
    // 4. 將以下兩條線加進去監控，你就能在按鈕按下那一刻看到波形！
    // ========================================================
    (* mark_debug = "true" *) wire debug_sys_awake = ~cpu_rst_n; // 按鈕按下為 1
    (* mark_debug = "true" *) wire [31:0] debug_pc = pc_wire;      // 查看 PC 有沒有開始變動

endmodule