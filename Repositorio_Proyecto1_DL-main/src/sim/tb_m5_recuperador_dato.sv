module tb_m5_recuperador_dato;

    logic [7:0] palabra_corregida;
    logic [3:0] dato_recuperado;


    m5_recuperador_dato dut (
        .palabra_corregida_pi (palabra_corregida),
        .dato_recuperado_po   (dato_recuperado)
    );


    initial begin

        // ========================================================
        // DATO 1010 = A
        //
        // Palabra SEC-DED:
        // {PG, i3, i2, i1, c2, i0, c1, c0}
        //  1    1   0   1   0   0   1   0
        // ========================================================

        palabra_corregida = 8'b11010010;

        #1;

        if (dato_recuperado !== 4'b1010)
            $fatal(1, "FALLO: recuperacion del dato 1010");

        $display("OK: dato 1010 recuperado");


        // ========================================================
        // DATO 0000
        // ========================================================

        palabra_corregida = 8'b00000000;

        #1;

        if (dato_recuperado !== 4'b0000)
            $fatal(1, "FALLO: recuperacion del dato 0000");

        $display("OK: dato 0000 recuperado");


        // ========================================================
        // DATO 1111
        //
        // Para esta prueba solo nos importa comprobar
        // las posiciones i3, i2, i1 e i0.
        // ========================================================

        palabra_corregida = 8'b01110100;

        #1;

        if (dato_recuperado !== 4'b1111)
            $fatal(1, "FALLO: recuperacion del dato 1111");

        $display("OK: dato 1111 recuperado");


        $display("==========================================");
        $display("TODAS LAS PRUEBAS DE RECUPERACION PASARON");
        $display("==========================================");

        $finish;

    end

endmodule