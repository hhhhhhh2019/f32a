module control_unit(input wire clk,
                    input wire rst);
   reg [31:0] A, B;
   reg [31:0] pc;
   reg [31:0] T, S, R;
   reg [29:0] dsp, rsp;
   reg [7:0]  cmd;
   reg [8:0]  mc;
   reg        carry, eam;

   reg [8:0]  cmd_mc;

   reg [1:0]  m_type;

   reg [1:0]  m_ALU1_mux_reg;
   reg [1:0]  m_ALU2_mux_reg;
   reg [1:0]  m_ALU_output_mux_reg;
   reg [2:0]  m_ALU_op;

   reg [3:0]  m_bus_input_mux_reg;
   reg [3:0]  m_bus_output_mux_reg;

   reg [2:0]  m_pc_offset;
   reg [2:0]  m_dsp_offset;
   reg [2:0]  m_rsp_offset;
   reg        m_mem_read;
   reg        m_mem_write;

   reg [8:0]  m_goto_address;
   reg [1:0]  m_goto_mux_reg;
   reg [31:0] m_goto_mask;
   reg        m_goto_cmd;

   microcode microcode(.clk(clk),
                       .mc(mc),
                       .cmd(cmd),

                       .cmd_mc(cmd_mc),

                       .m_type(m_type),

                       .m_ALU1_mux_reg(m_ALU1_mux_reg),
                       .m_ALU2_mux_reg(m_ALU2_mux_reg),
                       .m_ALU_output_mux_reg(m_ALU_output_mux_reg),
                       .m_ALU_op(m_ALU_op),

                       .m_bus_input_mux_reg(m_bus_input_mux_reg),
                       .m_bus_output_mux_reg(m_bus_output_mux_reg),

                       .m_pc_offset(m_pc_offset),
                       .m_dsp_offset(m_dsp_offset),
                       .m_rsp_offset(m_rsp_offset),
                       .m_mem_read(m_mem_read),
                       .m_mem_write(m_mem_write),

                       .m_goto_address(m_goto_address),
                       .m_goto_mux_reg(m_goto_mux_reg),
                       .m_goto_mask(m_goto_mask),
                       .m_goto_cmd(m_goto_cmd));

   reg [31:0] ALU1_input;
   reg [31:0] ALU2_input;
   wire [31:0] ALU_result;
   wire        new_carry;

   ALU alu(.a(ALU1_input),
           .b(ALU2_input),
           .result(ALU_result),
           .op(m_ALU_op),
           .carry(carry),
           .new_carry(new_carry),
           .eam(eam));

   always_comb begin
      case (m_ALU1_mux_reg)
        2'd0: ALU1_input = A;
        2'd1: ALU1_input = R;
        2'd2: ALU1_input = T;
        2'd3: ALU1_input = 32'd0;
      endcase

      case (m_ALU2_mux_reg)
        2'd0: ALU2_input = 32'd1;
        2'd1: ALU2_input = 32'd1;
        2'd2: ALU2_input = S;
        2'd3: ALU2_input = 32'd0;
      endcase
   end

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         A <= '0;
         B <= '0;
         T <= '0;
         S <= '0;
         R <= '0;
         pc <= 'h0000;
         dsp <= 'h1000;
         rsp <= 'h2000;
      end else begin
         case (m_type)
           2'b00: begin
              case (m_ALU_output_mux_reg)
                2'd0: A <= ALU_result;
                2'd1: B <= ALU_result;
                2'd2: T <= ALU_result;
                2'd3: R <= ALU_result;
              endcase
           end
           default:;
         endcase
      end
   end
endmodule
