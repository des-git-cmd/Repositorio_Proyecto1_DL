module tb_m7_indicador_error;

    logic [2:0] sindrome;
    logic       paridad_error;
    logic       error_sec;
    logic       error_ded;

    logic [3:0] codigo_error;


    m7_indicador_error dut (
        .sindrome_pi             (sindrome),
        .paridad_global_error_pi (paridad_error),
        .error_sec_pi            (error_sec),
        .error_ded_pi            (error_ded),
        .codigo_error_po         (codigo_error)
    );


    initial begin

        // ========================================================
        // SIN ERROR
        // ========================================================

        sindrome      = 3'b000;
        paridad_error = 1'b0;
        error_sec     = 1'b0;
        error_ded     = 1'b0;

        #1;

        if (codigo_error !== 4'h0)
            $fatal(1, "FALLO: sin error");

        $display("OK: sin error -> 0");


        // ========================================================
        // ERROR POSICIÓN 1 = c0
        // ========================================================

        sindrome      = 3'b001;
        paridad_error = 1'b1;
        error_sec     = 1'b1;
        error_ded     = 1'b0;

        #1;

        if (codigo_error !== 4'h1)
            $fatal(1, "FALLO: posicion 1");

        $display("OK: error posicion 1 -> 1");


        // ========================================================
        // ERROR POSICIÓN 2 = c1
        // ========================================================

        sindrome = 3'b010;

        #1;

        if (codigo_error !== 4'h2)
            $fatal(1, "FALLO: posicion 2");

        $display("OK: error posicion 2 -> 2");


        // ========================================================
        // ERROR POSICIÓN 3 = i0
        // ========================================================

        sindrome = 3'b011;

        #1;

        if (codigo_error !== 4'h3)
            $fatal(1, "FALLO: posicion 3");

        $display("OK: error posicion 3 -> 3");


        // ========================================================
        // ERROR POSICIÓN 4 = c2
        // ========================================================

        sindrome = 3'b100;

        #1;

        if (codigo_error !== 4'h4)
            $fatal(1, "FALLO: posicion 4");

        $display("OK: error posicion 4 -> 4");


        // ========================================================
        // ERROR POSICIÓN 5 = i1
        // ========================================================

        sindrome = 3'b101;

        #1;

        if (codigo_error !== 4'h5)
            $fatal(1, "FALLO: posicion 5");

        $display("OK: error posicion 5 -> 5");


        // ========================================================
        // ERROR POSICIÓN 6 = i2
        // ========================================================

        sindrome = 3'b110;

        #1;

        if (codigo_error !== 4'h6)
            $fatal(1, "FALLO: posicion 6");

        $display("OK: error posicion 6 -> 6");


        // ========================================================
        // ERROR POSICIÓN 7 = i3
        // ========================================================

        sindrome = 3'b111;

        #1;

        if (codigo_error !== 4'h7)
            $fatal(1, "FALLO: posicion 7");

        $display("OK: error posicion 7 -> 7");


        // ========================================================
        // ERROR EN PARIDAD GLOBAL = BIT 7 DE NUESTRA PALABRA
        // ========================================================

        sindrome      = 3'b000;
        paridad_error = 1'b1;
        error_sec     = 1'b1;
        error_ded     = 1'b0;

        #1;

        if (codigo_error !== 4'h8)
            $fatal(1, "FALLO: error paridad global");

        $display("OK: error paridad global -> 8");


        // ========================================================
        // ERROR DOBLE
        // ========================================================

        sindrome      = 3'b101;
        paridad_error = 1'b0;
        error_sec     = 1'b0;
        error_ded     = 1'b1;

        #1;

        if (codigo_error !== 4'hD)
            $fatal(1, "FALLO: error doble");

        $display("OK: error doble -> D");


        $display("=======================================");
        $display("TODAS LAS PRUEBAS DEL INDICADOR PASARON");
        $display("=======================================");

        $finish;

    end

endmodule