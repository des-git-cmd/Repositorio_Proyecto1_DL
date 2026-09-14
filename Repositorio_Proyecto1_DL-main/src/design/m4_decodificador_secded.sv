module m4_decodificador_secded (
    input  logic [7:0] palabra_pi,
    input  logic [2:0] sindrome_pi,
    input  logic       paridad_global_error_pi,

    output logic [7:0] palabra_corregida_po,
    output logic       error_sec_po,
    output logic       error_ded_po
);

    logic sindrome_cero;

    logic error_hamming;
    logic error_paridad_global;

    logic [7:0] mascara_correccion;


    // ============================================================
    // DETECTAR SI EL SÍNDROME ES 000
    // ============================================================

    assign sindrome_cero =
        ~sindrome_pi[2] &
        ~sindrome_pi[1] &
        ~sindrome_pi[0];


    // ============================================================
    // CLASIFICACIÓN SEC-DED
    //
    // Síndrome = 000, paridad = 0
    //     -> sin error
    //
    // Síndrome != 000, paridad = 1
    //     -> error sencillo en los 7 bits Hamming
    //
    // Síndrome = 000, paridad = 1
    //     -> error solamente en la paridad global
    //
    // Síndrome != 000, paridad = 0
    //     -> error doble
    // ============================================================

    assign error_hamming =
        paridad_global_error_pi &
        ~sindrome_cero;

    assign error_paridad_global =
        paridad_global_error_pi &
        sindrome_cero;


    // Hay un error sencillo corregible.
    assign error_sec_po =
        error_hamming |
        error_paridad_global;


    // Hay dos errores: solamente detectar, NO corregir.
    assign error_ded_po =
        ~paridad_global_error_pi &
        ~sindrome_cero;


    // ============================================================
    // MÁSCARA DE CORRECCIÓN
    //
    // síndrome 001 -> bit 0
    // síndrome 010 -> bit 1
    // síndrome 011 -> bit 2
    // síndrome 100 -> bit 3
    // síndrome 101 -> bit 4
    // síndrome 110 -> bit 5
    // síndrome 111 -> bit 6
    //
    // Si el síndrome es 000 y falla la paridad global:
    // corregimos bit 7.
    // ============================================================

    assign mascara_correccion[0] =
        error_hamming &
        ~sindrome_pi[2] &
        ~sindrome_pi[1] &
         sindrome_pi[0];

    assign mascara_correccion[1] =
        error_hamming &
        ~sindrome_pi[2] &
         sindrome_pi[1] &
        ~sindrome_pi[0];

    assign mascara_correccion[2] =
        error_hamming &
        ~sindrome_pi[2] &
         sindrome_pi[1] &
         sindrome_pi[0];

    assign mascara_correccion[3] =
        error_hamming &
         sindrome_pi[2] &
        ~sindrome_pi[1] &
        ~sindrome_pi[0];

    assign mascara_correccion[4] =
        error_hamming &
         sindrome_pi[2] &
        ~sindrome_pi[1] &
         sindrome_pi[0];

    assign mascara_correccion[5] =
        error_hamming &
         sindrome_pi[2] &
         sindrome_pi[1] &
        ~sindrome_pi[0];

    assign mascara_correccion[6] =
        error_hamming &
         sindrome_pi[2] &
         sindrome_pi[1] &
         sindrome_pi[0];


    // Bit 7 = paridad global.
    assign mascara_correccion[7] =
        error_paridad_global;


    // ============================================================
    // CORRECCIÓN
    //
    // XOR con 1 invierte el bit.
    // XOR con 0 lo deja igual.
    //
    // En error doble la máscara completa queda en 00000000,
    // por lo que NO intentamos corregir.
    // ============================================================

    assign palabra_corregida_po =
        palabra_pi ^ mascara_correccion;

endmodule