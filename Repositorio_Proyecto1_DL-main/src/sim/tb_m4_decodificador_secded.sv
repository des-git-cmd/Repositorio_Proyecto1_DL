module tb_m4_decodificador_secded;

    logic [7:0] palabra;

    logic [2:0] sindrome;
    logic       paridad_error;

    logic [7:0] palabra_corregida;
    logic       error_sec;
    logic       error_ded;


    // ============================================================
    // CALCULADOR DE SÍNDROME
    // ============================================================

    m3_calculador_sindrome calculador (
        .palabra_pi              (palabra),
        .sindrome_po             (sindrome),
        .paridad_global_error_po (paridad_error)
    );


    // ============================================================
    // DECODIFICADOR / CORRECTOR SEC-DED
    // ============================================================

    m4_decodificador_secded corrector (
        .palabra_pi                (palabra),
        .sindrome_pi               (sindrome),
        .paridad_global_error_pi   (paridad_error),
        .palabra_corregida_po      (palabra_corregida),
        .error_sec_po              (error_sec),
        .error_ded_po              (error_ded)
    );


    initial begin

        // ========================================================
        // PRUEBA 1: SIN ERROR
        // ========================================================

        palabra = 8'b11010010;

        #1;

        if (palabra_corregida !== 8'b11010010)
            $fatal(1, "FALLO: palabra sin error");

        if (error_sec !== 1'b0)
            $fatal(1, "FALLO: SEC activo sin error");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED activo sin error");

        $display("OK: palabra sin error");


        // ========================================================
        // PRUEBA 2: ERROR EN BIT 0
        // ========================================================

        palabra = 8'b11010011;

        #1;

        if (palabra_corregida !== 8'b11010010)
            $fatal(1, "FALLO: correccion bit 0");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC error bit 0");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED incorrecto bit 0");

        $display("OK: error bit 0 corregido");


        // ========================================================
        // PRUEBA 3: ERROR EN BIT 2
        // ========================================================

        palabra = 8'b11010110;

        #1;

        if (palabra_corregida !== 8'b11010010)
            $fatal(1, "FALLO: correccion bit 2");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC error bit 2");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED incorrecto bit 2");

        $display("OK: error bit 2 corregido");


        // ========================================================
        // PRUEBA 4: ERROR EN BIT 6
        // ========================================================

        palabra = 8'b10010010;

        #1;

        if (palabra_corregida !== 8'b11010010)
            $fatal(1, "FALLO: correccion bit 6");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC error bit 6");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED incorrecto bit 6");

        $display("OK: error bit 6 corregido");


        // ========================================================
        // PRUEBA 5: ERROR SOLO EN PARIDAD GLOBAL
        // ========================================================

        palabra = 8'b01010010;

        #1;

        if (palabra_corregida !== 8'b11010010)
            $fatal(1, "FALLO: correccion paridad global");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC error paridad global");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED incorrecto paridad global");

        $display("OK: error en paridad global corregido");


        // ========================================================
        // PRUEBA 6: DOS ERRORES, BITS 2 Y 5
        //
        // NO debe intentar corregir la palabra.
        // ========================================================

        palabra = 8'b11110110;

        #1;

        if (palabra_corregida !== 8'b11110110)
            $fatal(1, "FALLO: se intento corregir error doble");

        if (error_sec !== 1'b0)
            $fatal(1, "FALLO: SEC activo en error doble");

        if (error_ded !== 1'b1)
            $fatal(1, "FALLO: DED no detecto error doble");

        $display("OK: error doble detectado sin corregir");


        $display("========================================");
        $display("TODAS LAS PRUEBAS SEC-DED PASARON");
        $display("========================================");

        $finish;

    end

endmodule