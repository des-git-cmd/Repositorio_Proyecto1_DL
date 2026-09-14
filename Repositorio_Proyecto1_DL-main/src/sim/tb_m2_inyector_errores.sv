module tb_m2_inyector_errores;

    logic [7:0] palabra;

    logic [2:0] posicion_1;
    logic [2:0] posicion_2;

    logic habilitar;

    logic [7:0] resultado;


    m2_inyector_errores dut (
        .palabra_pi           (palabra),
        .posicion_error_1_pi  (posicion_1),
        .posicion_error_2_pi  (posicion_2),
        .habilitar_errores_pi (habilitar),
        .palabra_error_po     (resultado)
    );


    initial begin

        // Palabra usada para las pruebas
        palabra = 8'b10100101;


        // ========================================================
        // PRUEBA 1: SIN ERROR
        // ========================================================

        habilitar  = 1'b0;
        posicion_1 = 3'b000;
        posicion_2 = 3'b101;

        #1;

        if (resultado !== 8'b10100101)
            $fatal(1, "FALLO: caso sin error");

        $display("OK: sin error");


        // ========================================================
        // PRUEBA 2: UN ERROR EN BIT 0
        // Las dos posiciones son iguales.
        // ========================================================

        habilitar  = 1'b1;
        posicion_1 = 3'b000;
        posicion_2 = 3'b000;

        #1;

        if (resultado !== 8'b10100100)
            $fatal(1, "FALLO: error sencillo en bit 0");

        $display("OK: error sencillo bit 0");


        // ========================================================
        // PRUEBA 3: UN ERROR EN BIT 7
        // ========================================================

        posicion_1 = 3'b111;
        posicion_2 = 3'b111;

        #1;

        if (resultado !== 8'b00100101)
            $fatal(1, "FALLO: error sencillo en bit 7");

        $display("OK: error sencillo bit 7");


        // ========================================================
        // PRUEBA 4: DOS ERRORES
        // Bit 2 y bit 5.
        // ========================================================

        posicion_1 = 3'b010;
        posicion_2 = 3'b101;

        #1;

        if (resultado !== 8'b10000001)
            $fatal(1, "FALLO: errores en bits 2 y 5");

        $display("OK: error doble bits 2 y 5");


        $display("================================");
        $display("TODAS LAS PRUEBAS PASARON");
        $display("================================");

        $finish;

    end

endmodule