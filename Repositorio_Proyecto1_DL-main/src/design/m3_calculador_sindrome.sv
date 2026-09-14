module m3_calculador_sindrome (
    input  logic [7:0] palabra_pi,

    output logic [2:0] sindrome_po,
    output logic       paridad_global_error_po
);

    // ============================================================
    // CÁLCULO DEL SÍNDROME HAMMING (7,4)
    //
    // palabra_pi[7:0] =
    // {PG, i3, i2, i1, c2, i0, c1, c0}
    //
    // sindrome_po[0] -> comprobación de c0
    // sindrome_po[1] -> comprobación de c1
    // sindrome_po[2] -> comprobación de c2
    // ============================================================

    assign sindrome_po[0] =
        palabra_pi[0] ^
        palabra_pi[2] ^
        palabra_pi[4] ^
        palabra_pi[6];

    assign sindrome_po[1] =
        palabra_pi[1] ^
        palabra_pi[2] ^
        palabra_pi[5] ^
        palabra_pi[6];

    assign sindrome_po[2] =
        palabra_pi[3] ^
        palabra_pi[4] ^
        palabra_pi[5] ^
        palabra_pi[6];


    // ============================================================
    // PARIDAD GLOBAL SEC-DED
    //
    // 0 -> paridad total correcta
    // 1 -> paridad total incorrecta
    // ============================================================
    // a a a a
    assign paridad_global_error_po =
        palabra_pi[7] ^
        palabra_pi[6] ^
        palabra_pi[5] ^
        palabra_pi[4] ^
        palabra_pi[3] ^
        palabra_pi[2] ^
        palabra_pi[1] ^
        palabra_pi[0];

endmodule