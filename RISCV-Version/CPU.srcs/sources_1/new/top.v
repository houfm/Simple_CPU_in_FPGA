`timescale 1ns / 1ps

module top(clk,rst,led,switch,DIG,Y,row,col,backplace);
input           clk;
input           rst;
input [23:0]    switch;    
output[23:0]    led;
output[7:0]     DIG;//八位使能信号
output[7:0]     Y;//点亮数码管  
input  [3:0] row;
output [3:0] col;
input backplace;

cpuclk cpuclk(.clk_in1(clk),.clk_out1(clock));

// part I: 32-bit CPU
  wire        dmem_valid;        // 数据存储器（data memory）有效信号
  wire        dmem_good;         // 数据存储器（data memory）读取成功信号
  wire [31:0] dmem_writeData;    // 数据存储器（data memory）写入数据
  wire        dmem_memRead;      // 数据存储器（data memory）读取数据信号
  wire        dmem_memWrite;     // 数据存储器（data memory）写入数据信号
  wire [1:0]  dmem_maskMode;     // 数据存储器（data memory）写入模式
  wire        dmem_sext;         // 数据存储器（data memory）符号扩展
  wire [31:0] dmem_readData;     // 数据存储器（data memory）读取数据
  wire [31:0] dmem_readBack;     // 数据存储器（data memory）读取数据返回

  wire [31:0] cpu_imem_addr;     // CPU 指令存储器地址
  wire [31:0] cpu_imem_data;     // CPU 指令存储器数据

  wire [31:0] cpu_dmem_addr;       // CPU 数据存储器地址
  wire [31:0] cpu_dmem_data2cpu;   // CPU 数据存储器读取数据到 CPU
  wire        cpu_dmem_wen;        // CPU 数据存储器写入使能信号
  wire [31:0] cpu_dmem_cpu2data;   // CPU 数据存储器写入数据

  wire [31:0] imem_rd_addr;     // 指令存储器地址
  wire [31:0] imem_rd_data;     // 指令存储器数据

  wire [31:0] dmem_read_data;   // 数据存储器读取数据
  wire [31:0] dmem_write_data;  // 数据存储器写入数据
  wire [31:0] dmem_rd_addr;     // 数据存储器读取地址
  wire        dmem_wen;         // 数据存储器写入使能信号

  wire [31:0] dmem_rom_read_data; // 只读存储器（ROM）读取数据
  wire [31:0] dmem_rom_addr;      // 只读存储器（ROM）地址

  wire   [31:0] uart_read_data;
  wire   [31:0] uart_write_data;
  wire   [31:0] uart_addr;
  wire          uart_wen;

  cpu u_cpu(
            .clk(clk),
            .reset(reset),
            .imem_addr(cpu_imem_addr),
            .imem_valid(  ),
            .imem_good(1'b1),
            .imem_instr(cpu_imem_data),

            .dmem_addr(cpu_dmem_addr),
            .dmem_valid(dmem_valid),
            .dmem_good(dmem_good),
            .dmem_writeData(cpu_dmem_cpu2data),
            .dmem_memRead(dmem_memRead),
            .dmem_memWrite(cpu_dmem_wen),
            .dmem_maskMode(dmem_maskMode),
            .dmem_sext(dmem_sext),
            .dmem_readData(cpu_dmem_data2cpu),

            .dmem_readBack(dmem_readBack)
            );


sys_bus u_sys_bus(
    .cpu_imem_addr(cpu_imem_addr),
    .cpu_imem_data(cpu_imem_data),
     
    .cpu_dmem_addr(cpu_dmem_addr),          // device addr
    .cpu_dmem_data_in(cpu_dmem_cpu2data),   // cpu -> device
    .cpu_dmem_wen(cpu_dmem_wen),            // cpu -> device
    .cpu_dmem_data_out(cpu_dmem_data2cpu),  // device -> cpu

    .imem_addr(imem_rd_addr),                  // cpu -> imem
    .imem_data(imem_rd_data),                  // imem -> cpu
     
    .dmem_read_data(dmem_read_data),        // dmem -> cpu
    .dmem_write_data(dmem_write_data),      // cpu -> dmem
    .dmem_addr(dmem_rd_addr),               // cpu -> dmem
    .dmem_wen(dmem_wen),                    // cpu -> dmem
     
    .dmem_rom_read_data(dmem_rom_read_data),
    .dmem_rom_addr(dmem_rom_addr),
     
    .uart_read_data(uart_read_data),      // uart -> cpu
    .uart_write_data(uart_write_data),    // cpu -> uart
    .uart_addr(uart_addr),                // cpu -> uart
    .uart_wen(uart_wen)

);

// part II - Memory, IO

// instruction mem
program imem(
    .clk(clk),
    .wea(1'b0),
    .addr(imem_rd_addr[15:2]),
    .data(imem_rd_data)
);

prgram rom(
    .clk(clk),
    .wea(1'b0),
    .addr(dmem_rom_addr[15:2]),
    .data(dmem_rom_read_data)
);

// data memory
RAM dmem(
    .clka(clk),
    .wea(dmem_wen),
    .addra(dmem_rd_addr[15:2]),
    .dina(dmem_write_data),
    .douta(dmem_read_data)
);

// uart
uart_top u_uart(
                .rst_n(~reset)
                ,.clk(clk)
                ,.uart_rxd(uart_rx) // UART Recieve pin.
                ,.uart_txd(uart_tx) // UART transmit pin.
                ,.led(led)

                ,.uart_read_data(uart_read_data)     // uart -> cpu
                ,.uart_write_data(uart_write_data)    // cpu -> uart
                ,.uart_addr(uart_addr)          // cpu -> uart
                ,.uart_wen(uart_wen)
                );

endmodule
