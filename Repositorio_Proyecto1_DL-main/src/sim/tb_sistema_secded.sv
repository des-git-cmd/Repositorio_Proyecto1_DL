module tb_sistema_secded;

    // ============================================================
    // DATO ORIGINAL
    // ============================================================

    logic [3:0] dato_original;


    // ============================================================
    // CODIFICACIÓN
    // ============================================================

    logic [6:0] hamming;
    logic       paridad_global;
    logic [7:0] palabra_original;


    // ============================================================
    // INYECTOR DE ERRORES
    // ============================================================

    logic [2:0] posicion_error_1;
    logic [2:0] posicion_error_2;
    logic       habilitar_errores;

    logic [7:0] palabra_con_error;


    // ============================================================
    // RECEPTOR
    // ============================================================

    logic [2:0] sindrome;
    logic       paridad_error;

    logic [7:0] palabra_corregida;

    logic       error_sec;
    logic       error_ded;

    logic [3:0] dato_recuperado;

    logic [3:0] codigo_error;


    // ============================================================
    // M1 - CODIFICADOR HAMMING
    // ============================================================

    m1_codificador_hamming codificador (
        .dato_pi    (dato_original),
        .hamming_po (hamming)
    );


    // ============================================================
    // PARIDAD GLOBAL
    // ============================================================

    assign paridad_global = ^hamming;


    // ============================================================
    // PALABRA SEC-DED COMPLETA
    //
    // {PG, i3, i2, i1, c2, i0, c1, c0}
    // ============================================================

    assign palabra_original = {
        paridad_global,
        hamming
    };


    // ============================================================
    // M2 - INYECTOR DE ERRORES
    // ============================================================

    m2_inyector_errores inyector (
        .palabra_pi           (palabra_original),
        .posicion_error_1_pi  (posicion_error_1),
        .posicion_error_2_pi  (posicion_error_2),
        .habilitar_errores_pi (habilitar_errores),
        .palabra_error_po     (palabra_con_error)
    );


    // ============================================================
    // M3 - SÍNDROME
    // ============================================================

    m3_calculador_sindrome calculador (
        .palabra_pi               (palabra_con_error),
        .sindrome_po              (sindrome),
        .paridad_global_error_po  (paridad_error)
    );


    // ============================================================
    // M4 - CORRECCIÓN SEC-DED
    // ============================================================

    m4_decodificador_secded corrector (
        .palabra_pi               (palabra_con_error),
        .sindrome_pi              (sindrome),
        .paridad_global_error_pi  (paridad_error),

        .palabra_corregida_po     (palabra_corregida),
        .error_sec_po             (error_sec),
        .error_ded_po             (error_ded)
    );


    // ============================================================
    // M5 - RECUPERAR DATO
    // ============================================================

    m5_recuperador_dato recuperador (
        .palabra_corregida_pi (palabra_corregida),
        .dato_recuperado_po   (dato_recuperado)
    );


    // ============================================================
    // M7 - INDICADOR DE POSICIÓN / TIPO DE ERROR
    // ============================================================

    m7_indicador_error indicador (
        .sindrome_pi              (sindrome),
        .paridad_global_error_pi  (paridad_error),
        .error_sec_pi             (error_sec),
        .error_ded_pi             (error_ded),
        .codigo_error_po          (codigo_error)
    );


    // ============================================================
    // PRUEBAS
    // ============================================================

    initial begin

        // Usamos E = 1110 como dato principal.
        dato_original = 4'b1110;


        // ========================================================
        // PRUEBA 1
        // SIN ERRORES
        // ========================================================

        habilitar_errores = 1'b0;

        posicion_error_1 = 3'b000;
        posicion_error_2 = 3'b000;

        #1;

        if (dato_recuperado !== 4'b1110)
            $fatal(1, "FALLO: dato sin error");

        if (error_sec !== 1'b0)
            $fatal(1, "FALLO: SEC activo sin error");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED activo sin error");

        if (codigo_error !== 4'h0)
            $fatal(1, "FALLO: codigo sin error");

        $display("OK: E transmitida y recibida sin error");


        // ========================================================
        // PRUEBA 2
        // UN ERROR EN BIT 0 = c0
        //
        // Posición Hamming mostrada = 1
        // ========================================================

        habilitar_errores = 1'b1;

        posicion_error_1 = 3'b000;
        posicion_error_2 = 3'b000;

        #1;

        if (dato_recuperado !== 4'b1110)
            $fatal(1, "FALLO: no recupero E con error bit 0");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC no detecto error bit 0");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED activo con error sencillo");

        if (codigo_error !== 4'h1)
            $fatal(1, "FALLO: posicion error bit 0");

        $display("OK: error bit 0 corregido -> indicador 1");


        // ========================================================
        // PRUEBA 3
        // UN ERROR EN BIT 2 = i0
        //
        // Bit de palabra = 2
        // Posición Hamming = 3
        // Por eso el indicador debe mostrar 3.
        // ========================================================

        posicion_error_1 = 3'b010;
        posicion_error_2 = 3'b010;

        #1;

        if (dato_recuperado !== 4'b1110)
            $fatal(1, "FALLO: no recupero E con error bit 2");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC no detecto error bit 2");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED activo con error sencillo bit 2");

        if (codigo_error !== 4'h3)
            $fatal(1, "FALLO: posicion error bit 2");

        $display("OK: error bit 2 corregido -> indicador 3");


        // ========================================================
        // PRUEBA 4
        // ERROR EN BIT 7 = PARIDAD GLOBAL
        //
        // Nuestro indicador utiliza 8 para PG.
        // ========================================================

        posicion_error_1 = 3'b111;
        posicion_error_2 = 3'b111;

        #1;

        if (dato_recuperado !== 4'b1110)
            $fatal(1, "FALLO: dato con error en PG");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC no detecto error en PG");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED activo con error en PG");

        if (codigo_error !== 4'h8)
            $fatal(1, "FALLO: indicador error PG");

        $display("OK: error en PG corregido -> indicador 8");


        // ========================================================
        // PRUEBA 5
        // DOS ERRORES: BIT 2 Y BIT 5
        //
        // Debe detectar DED.
        // No debe intentar corregir la palabra.
        // El indicador debe mostrar D.
        // ========================================================

        posicion_error_1 = 3'b010;
        posicion_error_2 = 3'b101;

        #1;

        if (error_sec !== 1'b0)
            $fatal(1, "FALLO: SEC activo durante error doble");

        if (error_ded !== 1'b1)
            $fatal(1, "FALLO: DED no detecto dos errores");

        if (codigo_error !== 4'hD)
            $fatal(1, "FALLO: indicador de error doble");

        if (palabra_corregida !== palabra_con_error)
            $fatal(1, "FALLO: intento corregir un error doble");

        $display("OK: doble error detectado -> indicador D");


        // ========================================================
        // PRUEBA 6
        // CAMBIAR EL DATO ORIGINAL A A = 1010
        // Y COMPROBAR OTRA VEZ UN ERROR SENCILLO
        // ========================================================

        dato_original = 4'b1010;

        posicion_error_1 = 3'b100;
        posicion_error_2 = 3'b100;

        #1;

        if (dato_recuperado !== 4'b1010)
            $fatal(1, "FALLO: no recupero A");

        if (error_sec !== 1'b1)
            $fatal(1, "FALLO: SEC con dato A");

        if (error_ded !== 1'b0)
            $fatal(1, "FALLO: DED con dato A");

        if (codigo_error !== 4'h5)
            $fatal(1, "FALLO: posicion con dato A");

        $display("OK: A recuperada con error -> indicador 5");


        // ========================================================
        // FIN
        // ========================================================

        $display("");
        $display("==========================================");
        $display("   SISTEMA SEC-DED COMPLETO CORRECTO");
        $display("==========================================");
        $display("");

        $finish;

    end

endmodule