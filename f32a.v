module f32a(input wire clk,
            input wire rst);
   wire [31:0] address;
   wire [31:0]       cu_to_ram;
   reg [31:0]        ram_to_cu;
   wire              read;
   wire              write;

   RAM ram (.clk(clk),
            .address(address),
            .in(cu_to_ram),
            .out(ram_to_cu),
            .read(read),
            .write(write));

   control_unit control_unit(.clk(clk),
                             .rst(rst),
                             .mem_address(address),
                             .mem_in(ram_to_cu),
                             .mem_out(cu_to_ram),
                             .mem_read(read),
                             .mem_write(write));
endmodule
