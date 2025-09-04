`timescale 1ns/1ps

module tb_top;
	// Clock và reset
	reg clk;
	reg rst_n;

	// Kết nối tới DUT
	wire [31:0] instrF;
	wire        dmem_we;
	wire [31:0] dmem_addr;
	wire [31:0] dmem_wdata;
	wire [31:0] data_readM;
	wire [31:0] pcF;

	// DUT
	top dut (
		.clk(clk),
		.rst_n(rst_n),
		.instrF(instrF),
		.dmem_we(dmem_we),
		.dmem_addr(dmem_addr),
		.dmem_wdata(dmem_wdata),
		.data_readM(data_readM),
		.pcF(pcF)
	);

	// Instruction memory: dùng PC từ DUT để đọc lệnh
	imem imem_i (
		.pc(pcF),
		.ins(instrF)
	);

	// Data memory: nhận điều khiển từ DUT (qua memory stage bên trong)
	data_memory dmem_i (
		.clk(clk),
		.memrw(dmem_we),
		.address(dmem_addr),
		.data_write(dmem_wdata),
		.data_read(data_readM)
	);

	// Tạo clock 100 MHz (chu kỳ 10ns)
	always #5 clk = ~clk;

	initial begin
		// Khởi tạo
		clk   = 1'b0;
		rst_n = 1'b0;

		// Giữ reset một lúc
		#50;
		rst_n = 1'b1;

		// Thời gian mô phỏng tổng
		#5000;
		$display("\n[TB] Kết thúc mô phỏng tại thời điểm %0t ns", $time);
		$finish;
	end

	// Theo dõi một số tín hiệu chính
	initial begin
		$display("[TB] Bắt đầu mô phỏng");
		$monitor("t=%0t ns | pcF=%h | dmem_we=%b addr=%h wdata=%h rdata=%h",
			$time, pcF, dmem_we, dmem_addr, dmem_wdata, data_readM);
	end

endmodule


