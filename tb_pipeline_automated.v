module tb_pipeline_automated;

	reg clk;
	reg rst_n;

	integer total_error;

	parameter CLOCK_CYCLE = 2;

	initial clk = 0;
	always #(CLOCK_CYCLE/2) clk = ~clk;

	// Tín hiệu nối với DUT
	wire [31:0] pcF;
	wire [31:0] instrF;

	// Instruction memory giả lập trong testbench
	reg [31:0] instruction_memory [0:255];
	// Golden register file
	reg [31:0] golden_register_file [0:31];

	// DUT
	riscv DUT(
		.clk(clk),
		.rst_n(rst_n),
		.instrF(instrF),
		.pcF(pcF)
	);

	// Kết nối instrF từ bộ nhớ testbench
	assign instrF = instruction_memory[pcF[9:2]];

	// Reset register file (để khởi tạo quan sát rõ ràng khi cần)
	task reset_register_file;
		integer i;
		begin
			for (i = 0; i < 32; i = i + 1) begin
				DUT.core_inst.u_decode.reg_file[i] = 32'b0;
			end
		end
	endtask

	// Reset instruction memory
	task reset_imem;
		integer i;
		begin
			for (i = 0; i < 256; i = i + 1) begin
				instruction_memory[i] = 32'h00000013; // nop (addi x0, x0, 0)
			end
		end
	endtask

	// Dump register file hiện tại của DUT ra file hex (tiện đối chiếu golden)
	task dump_register_file_hex;
		input [8*256-1:0] out_path;
		integer fd;
		integer i;
		begin
			fd = $fopen(out_path, "w");
			if (fd == 0) begin
				$display("Cannot open %s for write", out_path);
			end else begin
				for (i = 0; i < 32; i = i + 1) begin
					$fdisplay(fd, "%08h", DUT.core_inst.u_decode.reg_file[i]);
				end
				$fclose(fd);
				$display("Dumped DUT reg_file to %s", out_path);
			end
		end
	endtask

	// Chạy test R-type
	task test_R_type;
		integer error_count;
		integer i;
		begin
			error_count = 0;

			$display("%t Starting R-type test...", $time);

			// Reset hệ thống
			rst_n = 0;
			reset_imem();
			#(CLOCK_CYCLE);
			@(negedge clk) rst_n = 1;

			// Nạp chương trình R-type vào instruction_memory
			$readmemh("./sim_pipeline/R-type/IMEM_hex.txt", instruction_memory);

			// Chạy một số chu kỳ đủ lớn để chương trình thực thi
			repeat (300) @(posedge clk);

			// Nạp golden và so sánh
			$readmemh("./sim_pipeline/R-type/golden_reg_file_hex.txt", golden_register_file);
			for (i = 0; i < 32; i = i + 1) begin
				if (DUT.core_inst.u_decode.reg_file[i] !== golden_register_file[i]) begin
					$display("Register mismatch at x%0d: DUT = %h, Golden = %h", i, DUT.core_inst.u_decode.reg_file[i], golden_register_file[i]);
					error_count = error_count + 1;
				end
			end

			if(error_count == 0) begin
				$display("%t R-type test passed!", $time);
			end else begin
				$display("%t R-type test failed with %0d errors.", $time, error_count);
				total_error = total_error + error_count;
			end
		end
	endtask

	initial begin
		total_error = 0;

		$display("==========================================");
		$display("RISC-V 5-Stage Pipeline Automated Testbench");
		$display("==========================================");

		// Chỉ chạy test R-type
		test_R_type();

		// Ghi lại kết quả thanh ghi quan sát được để tiện cập nhật golden nếu cần
		dump_register_file_hex("./sim_pipeline/R-type/observed_reg_file_hex.txt");

		$display("==========================================");
		$display("Total error count: %0d", total_error);
		$display("==========================================");

		if(total_error == 0) begin
			$display("All test cases Pass!\n");
		end else begin
			$display("Pipeline Test Failed!\n");
		end

		$finish;
	end

endmodule
