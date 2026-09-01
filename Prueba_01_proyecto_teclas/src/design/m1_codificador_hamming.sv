module m1_codificador_hamming (
    input  logic [3:0] dato_pi,
    output logic [6:0] hamming_po
);

    // Bits de paridad par
    assign hamming_po[3] = dato_pi[3] ^ dato_pi[2] ^ dato_pi[1]; // c2
    assign hamming_po[1] = dato_pi[3] ^ dato_pi[2] ^ dato_pi[0]; // c1
    assign hamming_po[0] = dato_pi[3] ^ dato_pi[1] ^ dato_pi[0]; // c0

    // Bits de información
    assign hamming_po[6] = dato_pi[3]; // i3
    assign hamming_po[5] = dato_pi[2]; // i2
    assign hamming_po[4] = dato_pi[1]; // i1
    assign hamming_po[2] = dato_pi[0]; // i0

endmodule