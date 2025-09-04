`timescale 1ns/1ps

module tb_riscv;
	reg clk;
	reg rst_n;

	// DUT: SoC tối giản đã tích hợp IMEM/DMEM và pipeline
	riscv dut (
		.clk(clk),
		.rst_n(rst_n)
	);

	// Tạo clock 100 MHz (chu kỳ 10ns)
	always #5 clk = ~clk;

	initial begin
		clk   = 1'b0;
		rst_n = 1'b0;
		#50;
		rst_n = 1'b1;

		#5000;
		$display("\n[TB] Kết thúc mô phỏng tại %0t ns", $time);
		$finish;
	end

	// Monitor một số tín hiệu nội bộ qua tham chiếu phân cấp
	// Lưu ý: các tên instance/wire dựa theo RISCV_Pipeline.v
	initial begin
		$display("[TB] Bắt đầu mô phỏng riscv");
		$monitor("t=%0t | pcF=%h | instr=%h | mem_we=%b addr=%h wdata=%h rdata=%h",
			$time,
			dut.pcF,
			dut.instrF,
			dut.memrwM,
			dut.ALUresM,
			dut.data_writeM,
			dut.data_readM);
	end

endmodule


