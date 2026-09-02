module top (
    input  logic [7:0] palabra_pi,
    output logic [5:0] led
);

    logic [3:0] dato;
    logic [6:0] hamming_referencia;
    logic       paridad_referencia;
    logic       palabra_correcta;

    // Recuperar los cuatro bits originales.
    assign dato = {
        palabra_pi[6], // DIP 1
        palabra_pi[5], // DIP 2
        palabra_pi[4], // DIP 3
        palabra_pi[2]  // DIP 4
    };

    // Codificador digital usado como referencia.
    m1_codificador_hamming referencia (
        .dato_pi   (dato),
        .hamming_po(hamming_referencia)
    );

    assign paridad_referencia = ^hamming_referencia;

    // Comparar los ocho bits físicos con el resultado esperado.
    assign palabra_correcta =
        (palabra_pi[6:0] == hamming_referencia) &&
        (palabra_pi[7]   == paridad_referencia);

    // Los LED de la Tang Nano 9K son activos en bajo.
    assign led[0] = ~dato[3];
    assign led[1] = ~dato[2];
    assign led[2] = ~dato[1];
    assign led[3] = ~dato[0];

    assign led[4] = ~palabra_pi[7];
    assign led[5] = ~palabra_correcta;

endmodule