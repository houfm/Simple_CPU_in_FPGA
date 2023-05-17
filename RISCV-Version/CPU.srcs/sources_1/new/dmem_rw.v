// dmem_rw模块定义
module dmem_rw(
  input reset, // 重置信号
  input clk, // 时钟信号
  input ex_mem_ctrl_data_mem_ctrl_memWrite, // 控制信号，指示是否进行写操作
  input [1:0] ex_mem_ctrl_data_mem_ctrl_maskMode, // 控制信号，控制写入时的掩码模式
  input [31:0] ex_mem_data_result, // 存储器地址
  input [31:0] ex_mem_data_regRData2, // 寄存器文件中的数据
  input ex_mem_ctrl_data_mem_ctrl_memRead, // 控制信号，指示是否进行读操作
  input ex_mem_ctrl_data_mem_ctrl_sext, // 控制信号，指示是否进行符号扩展

  output [31:0] dmem_addr, // 存储器地址
  output dmem_valid, // 存储器读写操作是否有效
  output [31:0] dmem_writeData, // 写入存储器的数据
  output dmem_memRead, // 控制信号，指示是否进行存储器读操作
  output dmem_memWrite, // 控制信号，指示是否进行存储器写操作
  output [1:0] dmem_maskMode, // 写入时的掩码模式
  output dmem_sext, // 是否进行符号扩展
  input [31:0] dmem_readData, // 从存储器中读取的数据
  output [31:0] dmem_readBack // 存储器中的数据
);

  wire dmem_sb_sh = ex_mem_ctrl_data_mem_ctrl_memWrite & (ex_mem_ctrl_data_mem_ctrl_maskMode == 2'h0 | ex_mem_ctrl_data_mem_ctrl_maskMode == 2'h1); // 写操作时是否进行掩码操作的标志位

  wire [31:0] dmem_writeData_w = dmem_sb_sh ? 32'h0 : ex_mem_data_regRData2; // 写入存储器的数据
  wire dmem_memWrite_w = dmem_sb_sh ? 1'h0 : ex_mem_ctrl_data_mem_ctrl_memWrite; // 控制信号，指示是否进行存储器写操作
  wire [1:0] dmem_maskMode_w = dmem_sb_sh ? 2'h2 : ex_mem_ctrl_data_mem_ctrl_maskMode; // 写入时的掩码模式

  reg dmem_sb_sh_tmp; // 写操作时是否进行掩码操作的标志位
  reg [31:0] dmem_addr_tmp; // 存储器地址
  reg [31:0] dmem_writeData_tmp; // 写入存储器的数据
  reg dmem_memWrite_tmp; // 控制信号，指示是否进行存储器写操作
  reg [1:0] dmem_maskMode_tmp; // 写入时的掩码模式
  reg dmem_sext_tmp; // 是否进行符号扩展
  reg [31:0] dmem_readData_tmp; // 从存储器中读取的数据

always @(posedge clk or posedge reset) begin
  if (reset) begin
    dmem_sb_sh_tmp <= 1'h0; // 将写操作时是否进行掩码操作的标志位清零
  end 
  else begin
    dmem_sb_sh_tmp <= dmem_sb_sh; // 将写操作时是否进行掩码操作的标志位更新
  end
end

always @(posedge clk or posedge reset) begin
if (reset) begin
  dmem_addr_tmp <= 32'h0; // 将存储器地址清零
  dmem_writeData_tmp <= 32'h0; // 将写入存储器的数据清零
  dmem_memWrite_tmp <= 1'b0; // 将控制信号，指示是否进行存储器写操作清零
  dmem_maskMode_tmp <= 2'b0; // 将写入时的掩码模式清零
  dmem_sext_tmp <= 1'b0; // 将符号扩展标志位清零
  dmem_readData_tmp <= 32'h0; // 将从存储器中读取的数据清零
end 
else begin
  dmem_addr_tmp <= ex_mem_data_result; // 更新存储器地址
  dmem_writeData_tmp <= ex_mem_data_regRData2; // 更新写入存储器的数据
  dmem_memWrite_tmp <= ex_mem_ctrl_data_mem_ctrl_memWrite; // 更新控制信号，指示是否进行存储器写操作
  dmem_maskMode_tmp <= ex_mem_ctrl_data_mem_ctrl_maskMode; // 更新写入时的掩码模式
  dmem_sext_tmp <= ex_mem_ctrl_data_mem_ctrl_sext; // 更新符号扩展标志位
  dmem_readData_tmp <= dmem_readData; // 更新从存储器中读取的数据
end
end

assign dmem_addr = dmem_sb_sh_tmp ? dmem_addr_tmp : ex_mem_data_result; // 存储器地址
assign dmem_valid = dmem_sb_sh_tmp | (dmem_memRead | dmem_memWrite); // 存储器读写操作是否有效
assign dmem_writeData = dmem_sb_sh_tmp ? dmem_writeData_tmp : dmem_writeData_w; // 写入存储器的数据
assign dmem_memRead = dmem_sb_sh_tmp ? 1'h0 : dmem_sb_sh | ex_mem_ctrl_data_mem_ctrl_memRead; // 控制信号，指示是否进行存储器读操作
assign dmem_memWrite = dmem_sb_sh_tmp ? dmem_memWrite_tmp : dmem_memWrite_w; // 控制信号，指示是否进行存储器写操作
assign dmem_maskMode = dmem_sb_sh_tmp ? dmem_maskMode_tmp : dmem_maskMode_w; // 写入时的掩码模式
assign dmem_sext = dmem_sb_sh_tmp ? dmem_sext_tmp : dmem_sb_sh | ex_mem_ctrl_data_mem_ctrl_sext; // 是否进行符号扩展
assign dmem_readBack = dmem_sb_sh_tmp ? dmem_readData_tmp : 32'hffffffff; // 存储器中的数据

endmodule