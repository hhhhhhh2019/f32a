module control_unit(input wire clk,
                    input wire rst,
                    input wire [31:0] mem_in,
                    output reg [31:0] mem_out,
                    output reg [31:0] mem_address,
                    output wire mem_read,
                    output wire mem_write);
   reg [31:0] A, B;
   reg [31:0] pc;
   reg [31:0] T, S, R, dsp, rsp;
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

   reg [1:0]  m_pc_offset;
   reg [1:0]  m_dsp_offset;
   reg [1:0]  m_rsp_offset;
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

   reg [31:0]  bus;

   ALU alu(.a(ALU1_input),
           .b(ALU2_input),
           .result(ALU_result),
           .op(m_ALU_op),
           .carry(carry),
           .new_carry(new_carry),
           .eam(eam));

   assign mem_read = m_type == 2'b10 && m_mem_read;
   assign mem_write = m_type == 2'b10 && m_mem_write;

   reg [31:0] goto_reg;
   wire       goto_cond = (goto_reg & m_goto_mask) == 0;

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

      case (m_bus_input_mux_reg)
        4'd0: bus = 0;
        4'd1: bus = 1;
        4'd2: bus = A;
        4'd3: bus = B;
        4'd4: bus = dsp;
        4'd5: bus = mem_in;
        4'd6: bus = pc;
        4'd7: bus = R;
        4'd8: bus = rsp;
        4'd9: bus = S;
        4'd10: bus = T;
        default: bus = 0;
      endcase

      case (m_goto_mux_reg)
        2'd0: goto_reg = A;
        2'd1: goto_reg = R;
        2'd2: goto_reg = T;
        default: goto_reg = 0;
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
         mc <= mc + 1;

         case (m_type)
           2'b00: begin
              case (m_ALU_output_mux_reg)
                2'd0: A <= ALU_result;
                2'd1: B <= ALU_result;
                2'd2: T <= ALU_result;
                2'd3: R <= ALU_result;
              endcase

              carry <= new_carry;
           end
           2'b01: begin
              case (m_bus_output_mux_reg)
                4'd0: A <= bus;
                4'd1: A[31] <= bus[0];
                4'd2: B <= bus;
                4'd3: carry <= bus[0];
                4'd4: cmd <= bus[7:0];
                4'd5: eam <= bus[0];
                4'd6: mem_address <= bus;
                4'd7: mem_out <= bus;
                4'd8: pc <= bus;
                4'd9: R <= bus;
                4'd10: S <= bus;
                4'd11: T <= bus;
                default:;
              endcase
           end
           2'b10: begin
              case (m_pc_offset)
                2'd1: pc <= pc + 1;
                2'd2: pc <= pc + 4;
                default:;
              endcase
              case (m_dsp_offset)
                2'd1: dsp <= dsp + 4;
                2'd2: dsp <= dsp - 4;
                default:;
              endcase
              case (m_rsp_offset)
                2'd1: rsp <= rsp + 4;
                2'd2: rsp <= rsp - 4;
                default:;
              endcase
           end
           2'b11: begin
              if (m_goto_cmd)
                mc <= cmd_mc;
              else if (goto_cond)
                mc <= m_goto_address;
           end
         endcase
      end
   end
endmodule
