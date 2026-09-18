`timescale 1ns/1ps

module tb_top_visualizacion;

    logic [7:0] palabra;
    logic [2:0] posicion_1;
    logic [2:0] posicion_2;
    logic habilitar_errores;
    logic modo_tx;

    tri [7:0] enlace;
    wire [5:0] led;
    wire [6:0] seg;

    // Nombres del testbench segun su funcion actual.
    wire display_tx;
    wire display_rx;

    logic [3:0] valor_esperado;
    wire [6:0] segmentos_esperados;

    top dut (
        .palabra_pi                 (palabra),
        .posicion_error_1_pi         (posicion_1),
        .posicion_error_2_pi         (posicion_2),
        .habilitar_errores_pi        (habilitar_errores),
        .modo_tx_pi                 (modo_tx),
        .enlace_io                  (enlace),
        .led                        (led),
        .seg                        (seg),
        .habilitar_display_dato_po   (display_tx),
        .habilitar_display_error_po  (display_rx)
    );

    // Referencia para comprobar la seleccion del dato.
    // No sustituye una prueba independiente de las ecuaciones de M6.
    m6_display_7segmentos referencia_display (
        .dato_pi (valor_esperado),
        .seg_po  (segmentos_esperados)
    );

    task automatic comprobar_vista (
        input logic modo,
        input logic [3:0] valor
    );
        begin
            modo_tx = modo;
            valor_esperado = valor;
            #1;

            if (seg !== segmentos_esperados)
                $fatal(1,
                    "FALLO: DIP 8=%b, valor esperado=%h",
                    modo, valor);

            // DIP 8 = 1: solo indicador TX.
            // DIP 8 = 0: solo indicador RX.
            if (display_tx !== modo)
                $fatal(1, "FALLO: habilitacion indicador TX");

            if (display_rx !== ~modo)
                $fatal(1, "FALLO: habilitacion indicador RX");

            // led[0] representa el bit mas significativo.
            if ({led[0], led[1], led[2], led[3]} !== ~valor)
                $fatal(1, "FALLO: LED del dato seleccionado");

            if (enlace !== 8'bzzzzzzzz)
                $fatal(1, "FALLO: bus externo no deshabilitado");
        end
    endtask

    task automatic comprobar_receptor (
        input logic sec,
        input logic ded
    );
        begin
            if (modo_tx !== 1'b0)
                $fatal(1, "FALLO: prueba RX fuera de modo RX");

            if (led[4] !== ~sec)
                $fatal(1, "FALLO: indicador SEC");

            if (led[5] !== ~ded)
                $fatal(1, "FALLO: indicador DED");
        end
    endtask

    task automatic comprobar_transmisor (
        input logic error_insertado
    );
        begin
            if (modo_tx !== 1'b1)
                $fatal(1, "FALLO: prueba TX fuera de modo TX");

            if (led[4] !== ~error_insertado)
                $fatal(1, "FALLO: indicador de error insertado");

            // LED activo en bajo:
            // palabra con paridad global par -> LED encendido.
            if (led[5] !== (^palabra))
                $fatal(1, "FALLO: indicador de paridad en TX");
        end
    endtask

    initial begin
        // Palabra simulada del codificador fisico.
        // E = 1110 -> palabra SEC-DED = 78 hexadecimal.
        palabra = 8'h78;
        posicion_1 = 3'd0;
        posicion_2 = 3'd0;
        habilitar_errores = 1'b0;
        modo_tx = 1'b1;
        valor_esperado = 4'hE;

        // ========================================================
        // 1. TX SIN ERRORES
        // ========================================================

        comprobar_vista(1'b1, 4'hE);
        comprobar_transmisor(1'b0);

        $display("OK: DIP 8=1; primer indicador muestra E");

        // ========================================================
        // 2. RX SIN ERRORES
        // ========================================================

        comprobar_vista(1'b0, 4'hE);
        comprobar_receptor(1'b0, 1'b0);

        $display("OK: DIP 8=0; segundo indicador muestra E");

        // ========================================================
        // 3. ERROR SENCILLO EN INDICE 2
        // ========================================================

        habilitar_errores = 1'b1;
        posicion_1 = 3'd2;
        posicion_2 = 3'd2;

        comprobar_vista(1'b1, 4'hE);
        comprobar_transmisor(1'b1);

        comprobar_vista(1'b0, 4'hE);
        comprobar_receptor(1'b1, 1'b0);

        $display("OK: error sencillo; TX muestra E y RX recupera E");

        // ========================================================
        // 4. ERROR EN PARIDAD GLOBAL
        // ========================================================

        posicion_1 = 3'd7;
        posicion_2 = 3'd7;

        comprobar_vista(1'b1, 4'hE);
        comprobar_transmisor(1'b1);

        comprobar_vista(1'b0, 4'hE);
        comprobar_receptor(1'b1, 1'b0);

        $display("OK: error en PG; RX conserva E y activa SEC");

        // ========================================================
        // 5. DOBLE ERROR EN INDICES 2 Y 5
        //
        // Se invierten i0 e i2:
        // E = 1110 -> B = 1011.
        // RX muestra B, pero DED indica que NO es un dato valido.
        // No se corrige un doble error.
        // ========================================================

        posicion_1 = 3'd2;
        posicion_2 = 3'd5;

        comprobar_vista(1'b1, 4'hE);
        comprobar_transmisor(1'b1);

        comprobar_vista(1'b0, 4'hB);
        comprobar_receptor(1'b0, 1'b1);

        $display("OK: doble error; TX muestra E, RX muestra B y activa DED");

        // ========================================================
        // 6. A CON ERROR SENCILLO EN INDICE 4
        // ========================================================

        palabra = 8'hD2;
        posicion_1 = 3'd4;
        posicion_2 = 3'd4;

        comprobar_vista(1'b1, 4'hA);
        comprobar_transmisor(1'b1);

        comprobar_vista(1'b0, 4'hA);
        comprobar_receptor(1'b1, 1'b0);

        $display("OK: TX muestra A y RX recupera A");

        // ========================================================
        // 7. DESHABILITAR ERRORES
        // ========================================================

        habilitar_errores = 1'b0;

        comprobar_vista(1'b1, 4'hA);
        comprobar_transmisor(1'b0);

        comprobar_vista(1'b0, 4'hA);
        comprobar_receptor(1'b0, 1'b0);

        $display("OK: errores deshabilitados; SEC y DED apagados");
        $display("VISUALIZACION TX/RX: TODAS LAS PRUEBAS PASARON");

        $finish;
    end

endmodule