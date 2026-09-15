`timescale 1ns/1ps

module tb_top_visualizacion;

    logic [7:0] palabra;
    logic [2:0] posicion_1;
    logic [2:0] posicion_2;
    logic habilitar_errores;
    logic modo_tx;
    logic seleccionar_error;

    tri [7:0] enlace;
    wire [5:0] led;
    wire [6:0] seg;
    wire display_dato;
    wire display_error;

    logic [3:0] valor_esperado;
    wire [6:0] segmentos_esperados;

    top dut (
        .palabra_pi                 (palabra),
        .posicion_error_1_pi        (posicion_1),
        .posicion_error_2_pi        (posicion_2),
        .habilitar_errores_pi       (habilitar_errores),
        .modo_tx_pi                 (modo_tx),
        .seleccionar_error_pi       (seleccionar_error),
        .enlace_io                  (enlace),
        .led                        (led),
        .seg                        (seg),
        .habilitar_display_dato_po  (display_dato),
        .habilitar_display_error_po (display_error)
    );

    // Referencia para verificar la seleccion del valor.
    // No sustituye el testbench exclusivo de M6.
    m6_display_7segmentos referencia_display (
        .dato_pi (valor_esperado),
        .seg_po  (segmentos_esperados)
    );

    task automatic comprobar_vista (
        input logic selector,
        input logic [3:0] valor
    );
        begin
            seleccionar_error = selector;
            valor_esperado = valor;
            #1;

            if (seg !== segmentos_esperados)
                $fatal(1,
                    "FALLO: selector=%b valor esperado=%h",
                    selector, valor);

            if (display_dato !== ~selector)
                $fatal(1, "FALLO: habilitacion display dato");

            if (display_error !== selector)
                $fatal(1, "FALLO: habilitacion display error");

            if (enlace !== 8'bzzzzzzzz)
                $fatal(1, "FALLO: bus externo no deshabilitado");
        end
    endtask

    task automatic comprobar_receptor (
        input logic [3:0] dato,
        input logic sec,
        input logic ded
    );
        begin
            // led[0] corresponde al bit mas significativo.
            // Los LED son activos en bajo.
            if ({led[0], led[1], led[2], led[3]} !== ~dato)
                $fatal(1, "FALLO: LED del dato recuperado");

            if (led[4] !== ~sec)
                $fatal(1, "FALLO: indicador SEC");

            if (led[5] !== ~ded)
                $fatal(1, "FALLO: indicador DED");
        end
    endtask

    initial begin
        // Entrada simulada equivalente a la palabra fisica de E.
        palabra = 8'h78;
        posicion_1 = 3'd0;
        posicion_2 = 3'd0;
        habilitar_errores = 1'b0;
        modo_tx = 1'b1;
        seleccionar_error = 1'b0;
        valor_esperado = 4'hE;

        // 1. TX sin errores.
        comprobar_vista(1'b0, 4'hE);
        comprobar_vista(1'b1, 4'h0);

        // Orden del vector: led[5] hasta led[0].
        if (led !== 6'b011000)
            $fatal(1, "FALLO: LED en TX sin errores");

        $display("OK: TX muestra E y codigo 0");

        // 2. RX sin errores.
        modo_tx = 1'b0;
        comprobar_vista(1'b0, 4'hE);
        comprobar_vista(1'b1, 4'h0);
        comprobar_receptor(4'hE, 1'b0, 1'b0);

        $display("OK: RX muestra E y codigo 0");

        // 3. Un error en indice 2: posicion Hamming 3.
        habilitar_errores = 1'b1;
        posicion_1 = 3'd2;
        posicion_2 = 3'd2;

        comprobar_vista(1'b0, 4'hE);
        comprobar_vista(1'b1, 4'h3);
        comprobar_receptor(4'hE, 1'b1, 1'b0);

        $display("OK: error sencillo corregido; codigo 3");

        // 4. Error en paridad global.
        posicion_1 = 3'd7;
        posicion_2 = 3'd7;

        comprobar_vista(1'b0, 4'hE);
        comprobar_vista(1'b1, 4'h8);
        comprobar_receptor(4'hE, 1'b1, 1'b0);

        $display("OK: error en PG; codigo 8");

        // 5. Dos errores: indices 2 y 5.
        // Se invierten i0 e i2:
        // E = 1110 -> B = 1011.
        // DED debe detectarlos sin corregir el dato.
        posicion_1 = 3'd2;
        posicion_2 = 3'd5;

        comprobar_vista(1'b0, 4'hB);
        comprobar_vista(1'b1, 4'hD);
        comprobar_receptor(4'hB, 1'b0, 1'b1);

        $display("OK: doble error detectado; dato B y codigo D");

        // En TX sigue mostrandose el dato original E.
        modo_tx = 1'b1;
        comprobar_vista(1'b0, 4'hE);

        if (led[4] !== 1'b0)
            $fatal(1, "FALLO: indicador de error insertado");

        // 6. A con un error en indice 4: posicion Hamming 5.
        palabra = 8'hD2;
        posicion_1 = 3'd4;
        posicion_2 = 3'd4;
        modo_tx = 1'b0;

        comprobar_vista(1'b0, 4'hA);
        comprobar_vista(1'b1, 4'h5);
        comprobar_receptor(4'hA, 1'b1, 1'b0);

        $display("OK: A recuperada; codigo 5");
        $display("VISUALIZACION DEL TOP: TODAS LAS PRUEBAS PASARON");
        $finish;
    end

endmodule