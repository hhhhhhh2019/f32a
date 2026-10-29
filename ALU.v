module ALU(input wire [31:0] a,
           input wire [31:0] b,
           input wire [2:0]  op,
           output reg [31:0] result,
           input wire        carry,
           input wire        eam,
           output reg        new_carry);
   always_comb begin
      case (op)
        3'd0: {new_carry, result} = a + b + (carry&eam);
        3'd1: {new_carry, result} = {1'b0, a & b};
        3'd2: {new_carry, result} = {1'b0, a ^ b};
        3'd3: {new_carry, result} = {1'b0, a << 1};
        3'd4: {new_carry, result} = {1'b0, a >> 1};
        3'd5: {new_carry, result} = {1'b0, ~a};
        default: {new_carry, result} = 'b0;
      endcase
   end
endmodule
