module m5_recuperador_dato (
    input  logic [7:0] palabra_corregida_pi,
    output logic [3:0] dato_recuperado_po
);

    // ============================================================
    // RECUPERACIÓN DEL DATO ORIGINAL
    //
    // palabra_corregida_pi[7:0] =
    // {PG, i3, i2, i1, c2, i0, c1, c0}
    //
    // dato_recuperado_po =
    // {i3, i2, i1, i0}
    // ============================================================

    assign dato_recuperado_po[3] = palabra_corregida_pi[6];
    assign dato_recuperado_po[2] = palabra_corregida_pi[5];
    assign dato_recuperado_po[1] = palabra_corregida_pi[4];
    assign dato_recuperado_po[0] = palabra_corregida_pi[2];

endmodule