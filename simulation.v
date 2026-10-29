`timescale 1ns / 1ps

module simulation;
   reg clk;
   reg reset;

   f32a uut(.clk(clk),
            .rst(reset));

   always #5 clk = ~clk;

   initial begin
      $dumpfile("simulation.vcd");
      $dumpvars(0, simulation);

      clk = 0;
      reset = 1;

      #20;
      reset = 0;

      #5000;

      $display("Симуляция окончена. Открывайте файл в GTKWave!");
      $finish;
   end
endmodule
