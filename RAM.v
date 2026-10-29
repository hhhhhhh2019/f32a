module RAM#(parameter ADDR_W = 10
            )(input wire              clk,
              input wire [ADDR_W-1:0] address,
              input wire [31:0]       in,
              output reg [31:0]       out,
              input wire              read,
              input wire              write);
   reg [7:0] ram[0:1 << ADDR_W - 1];

   initial begin
      $readmemh("ram.hex", ram);
   end

   always @(posedge clk) begin
      if (read)
        out <= {ram[address+3],ram[address+2],ram[address+1],ram[address+0]};

      if (write)
        {ram[address+3],ram[address+2],ram[address+1],ram[address+0]} <= in;
   end
endmodule
