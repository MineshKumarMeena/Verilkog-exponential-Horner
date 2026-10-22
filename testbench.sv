
`timescale 1ns/1ps

module tb_exp;

    parameter real TOLERANCE = 0.0001;
    parameter real TOLER_ANCE = 0.001;

    reg clk, rst, start;
    reg signed [31:0] x;

    wire signed [31:0] y;
    wire done;

    exp_horner uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x(x),
        .y(y),
        .done(done)
    );

    always #5 clk = ~clk;

    task run_test;
        input signed [31:0] x_fixed;
        input real x_value;
        input real expected_exact;

        real x_used;
        real actual;
        real expected_poly;
        real implementation_error;
        real approximation_error;
        real total_error;

        begin
            @(negedge clk);
            x = x_fixed;
            start = 1;

            @(negedge clk);
            start = 0;

            wait(done == 1);

            actual = $itor(y) / 65536.0;
            x_used = $itor(x_fixed) / 65536.0;

            expected_poly =
                1.0 + x_used *
                (1.0 + x_used *
                (0.5 + x_used *
                (1.0/6.0 + x_used/24.0)));

            implementation_error = actual - expected_poly;
            if (implementation_error < 0)
                implementation_error = -implementation_error;

            approximation_error = expected_poly - expected_exact;
            if (approximation_error < 0)
                approximation_error = -approximation_error;

            total_error = actual - expected_exact;
            if (total_error < 0)
                total_error = -total_error;

            $display("\nx = %f", x_used);
            $display("Hardware output       = %f", actual);
            $display("Taylor polynomial     = %f", expected_poly);
            $display("Exact exponential     = %f", expected_exact);
            $display("Implementation error  = %f", implementation_error);
            $display("Approximation error   = %f", approximation_error);
            $display("Total error            = %f", total_error);
 
          if (implementation_error <= TOLERANCE && total_error <= TOLER_ANCE)
                $display("PASS: within tolerance");
            else
                $display("FAIL: exceeds tolerance");

            @(negedge clk);
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        x = 0;

        repeat (2) @(negedge clk);
        rst = 0;

        run_test(-65536, -1.0,  0.367879);
        run_test(-49152, -0.75, 0.472367);
        run_test(-32768,  -0.5, 0.606531);
        run_test(-16384, -0.25, 0.778801);
        run_test(0,        0.0, 1.000000);
        run_test(6554,     0.1, 1.105177);
        run_test(16384,   0.25, 1.284025);
        run_test(32768,    0.5, 1.648721);
        run_test(49152,   0.75, 2.117000);
        run_test(65536,    1.0, 2.718282);

        $display("\nAll tests completed.");
        $finish;
    end

endmodule
