module microcode#(parameter MC_W = 10
                  )(input wire            clk,
                    input wire [MC_W-1:0] mc,

                    output reg [1:0]      m_type,

                    output reg [MC_W-1:0] m_goto_address,
                    output reg [31:0]     m_goto_mask,
                    output reg [2:0]      m_goto_mux_reg);
   reg [100:0] rom[0:1 << MC_W - 1];

   always @(posedge clk) begin
      m_type <= rom[mc][1:0];

      {m_goto_address, m_goto_mask, m_goto_mux_reg} <= rom[mc][46:2];
   end
endmodule
