// 设备地址空间
// 0x0000_0000 - .+ ROM (byte 到 word)
// 0x1000_0000 - .+ RAM (byte 到 word)
// 0x2000_0000 - .+ uart (byte 到 word)
// 0x3000_0000 - .+ 其他 (byte 到 word)
// 0xc000_0000 - .+ 设备 io (byte 到 word)

// sys_bus模块定义
module sys_bus (
input [31:0] cpu_imem_addr, // CPU指令地址
output [31:0] cpu_imem_data, // CPU指令数据

output [31:0] imem_addr,         // CPU -> 指令存储器
input  [31:0] imem_data,         // 指令存储器 -> CPU

input  [31:0] cpu_dmem_addr,     // 设备地址
input  [31:0] cpu_dmem_data_in,  // CPU -> 设备
input         cpu_dmem_wen,      // CPU -> 设备写使能
output reg [31:0] cpu_dmem_data_out, // 设备 -> CPU
input  [31:0] dmem_read_data,    // 设备 -> CPU读数据
output [31:0] dmem_write_data,   // CPU -> 设备写数据
output [31:0] dmem_addr,         // CPU -> 设备地址
output reg    dmem_wen,          // CPU -> 设备写使能
input  [31:0] dmem_rom_read_data, // ROM -> CPU读数据
output [31:0] dmem_rom_addr,     // CPU -> ROM地址
input  [31:0] uart_read_data,    // UART -> CPU读数据
output [31:0] uart_write_data,   // CPU -> UART写数据
output [31:0] uart_addr,         // CPU -> UART地址
output reg    uart_wen           // CPU -> UART写使能
);

    assign imem_addr = cpu_imem_addr;     // CPU地址直接连接到指令存储器地址
    assign cpu_imem_data = imem_data;     // 指令存储器数据直接连接到CPU指令数据输出

    assign dmem_addr = cpu_dmem_addr;     // CPU地址直接连接到设备地址
    assign dmem_write_data = cpu_dmem_data_in; // CPU写数据直接连接到设备写数据

    assign dmem_rom_addr = cpu_dmem_addr; // CPU地址直接连接到ROM地址

    assign uart_addr = cpu_dmem_addr;     // CPU地址直接连接到UART地址
    assign uart_write_data = cpu_dmem_data_in; // CPU写数据直接连接到UART写数据

    always @(*) begin
        case (cpu_dmem_addr[31:28])  // 根据CPU地址的高4位进行分配
            4'h0: begin     // ROM
                cpu_dmem_data_out <= dmem_rom_read_data; // ROM读数据直接连接到设备 -> CPU数据输出
                dmem_wen <= 0; // 设备写使能为0
                uart_wen <= 0; // UART写使能为0
            end
            4'h1: begin     // RAM
                dmem_wen <= cpu_dmem_wen; // 设备写使能由CPU写使能决定
                cpu_dmem_data_out <= dmem_read_data; // 设备读数据直接连接到设备 -> CPU数据输出
                uart_wen <= 0; // UART写使能为0
            end
            4'h2: begin     // UART io
                uart_wen <= cpu_dmem_wen; // UART写使能由CPU写使能决定
                cpu_dmem_data_out <= uart_read_data; // UART读数据直接连接到设备 -> CPU数据输出
                dmem_wen <= 0; // 设备写使能为0
            end
            default:   begin // 其他 IO
                dmem_wen <= 0; // 设备写使能为0
                uart_wen <= 0; // UART写使能为0
                cpu_dmem_data_out <= 0; // 设备 -> CPU数据输出为0
            end
        endcase
    end

endmodule