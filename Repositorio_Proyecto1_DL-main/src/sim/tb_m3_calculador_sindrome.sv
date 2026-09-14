module tb_m3_calculador_sindrome;

    logic [7:0] palabra;

    logic [2:0] sindrome;
    logic       paridad_error;


    m3_calculador_sindrome dut (
        .palabra_pi              (palabra),
        .sindrome_po             (sindrome),
        .paridad_global_error_po (paridad_error)
    );


    initial begin

        // ========================================================
        // PALABRA CORRECTA
        //
        // Dato original = 1010
        // Palabra SEC-DED = 11010010
        // ========================================================

        palabra = 8'b11010010;

        #1;

        if (sindrome !== 3'b000)
            $fatal(1, "FALLO: sindrome sin error");

        if (paridad_error !== 1'b0)
            $fatal(1, "FALLO: paridad sin error");

        $display("OK: palabra sin error");


        // ========================================================
        // ERROR EN BIT 0 -> posición Hamming 1
        // ========================================================

        palabra = 8'b11010011;

        #1;

        if (sindrome !== 3'b001)
            $fatal(1, "FALLO: error bit 0");

        if (paridad_error !== 1'b1)
            $fatal(1, "FALLO: paridad error bit 0");

        $display("OK: error bit 0 -> sindrome 001");


        // ========================================================
        // ERROR EN BIT 2 -> posición Hamming 3
        // ========================================================

        palabra = 8'b11010110;

        #1;

        if (sindrome !== 3'b011)
            $fatal(1, "FALLO: error bit 2");

        if (paridad_error !== 1'b1)
            $fatal(1, "FALLO: paridad error bit 2");

        $display("OK: error bit 2 -> sindrome 011");


        // ========================================================
        // ERROR EN BIT 6 -> posición Hamming 7
        // ========================================================

        palabra = 8'b10010010;

        #1;

        if (sindrome !== 3'b111)
            $fatal(1, "FALLO: error bit 6");

        if (paridad_error !== 1'b1)
            $fatal(1, "FALLO: paridad error bit 6");

        $display("OK: error bit 6 -> sindrome 111");


        // ========================================================
        // ERROR ÚNICAMENTE EN PARIDAD GLOBAL
        // ========================================================

        palabra = 8'b01010010;

        #1;

        if (sindrome !== 3'b000)
            $fatal(1, "FALLO: error en paridad global");

        if (paridad_error !== 1'b1)
            $fatal(1, "FALLO: deteccion paridad global");

        $display("OK: error solamente en paridad global");


        // ========================================================
        // DOS ERRORES: BIT 2 Y BIT 5
        // ========================================================

        palabra = 8'b11110110;

        #1;

        if (sindrome !== 3'b101)
            $fatal(1, "FALLO: sindrome error doble");

        if (paridad_error !== 1'b0)
            $fatal(1, "FALLO: paridad error doble");

        $display("OK: error doble detectado");


        $display("======================================");
        $display("TODAS LAS PRUEBAS DE SINDROME PASARON");
        $display("======================================");

        $finish;

    end

endmodule