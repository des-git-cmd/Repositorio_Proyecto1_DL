module m7_indicador_error (
    input  logic [2:0] sindrome_pi,
    input  logic       paridad_global_error_pi,
    input  logic       error_sec_pi,
    input  logic       error_ded_pi,

    output logic [3:0] codigo_error_po
);

    logic sindrome_cero;
    logic error_hamming;
    logic error_paridad_global;


    // ============================================================
    // DETECTAR SÍNDROME 000
    // ============================================================

    assign sindrome_cero =
        ~sindrome_pi[2] &
        ~sindrome_pi[1] &
        ~sindrome_pi[0];


    // ============================================================
    // TIPO DE ERROR SENCILLO
    //
    // SEC + síndrome distinto de 000:
    // error en alguna de las posiciones Hamming 1 a 7.
    //
    // SEC + síndrome 000:
    // error únicamente en la paridad global.
    // ============================================================

    assign error_hamming =
        error_sec_pi &
        paridad_global_error_pi &
        ~sindrome_cero;

    assign error_paridad_global =
        error_sec_pi &
        paridad_global_error_pi &
        sindrome_cero;


    // ============================================================
    // CÓDIGO PARA EL DISPLAY
    //
    // Sin error:
    //      0000 = 0
    //
    // Error sencillo Hamming:
    //      0001 = 1
    //      0010 = 2
    //      ...
    //      0111 = 7
    //
    // Error en paridad global:
    //      1000 = 8
    //
    // Error doble:
    //      1101 = D
    // ============================================================

    assign codigo_error_po[3] =
        error_ded_pi |
        error_paridad_global;

    assign codigo_error_po[2] =
        error_ded_pi |
        (error_hamming & sindrome_pi[2]);

    assign codigo_error_po[1] =
        error_hamming &
        sindrome_pi[1];

    assign codigo_error_po[0] =
        error_ded_pi |
        (error_hamming & sindrome_pi[0]);

endmodule