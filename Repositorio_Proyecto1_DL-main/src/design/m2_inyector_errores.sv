module m2_inyector_errores (
    input  logic [7:0] palabra_pi,

    input  logic [2:0] posicion_error_1_pi,
    input  logic [2:0] posicion_error_2_pi,

    input  logic       habilitar_errores_pi,

    output logic [7:0] palabra_error_po
);

    logic [7:0] mascara_error_1;
    logic [7:0] mascara_error_2;

    logic misma_posicion;


    // ============================================================
    // COMPROBAR SI LAS DOS POSICIONES SON IGUALES
    // ============================================================

    assign misma_posicion =
        ~(posicion_error_1_pi[2] ^ posicion_error_2_pi[2]) &
        ~(posicion_error_1_pi[1] ^ posicion_error_2_pi[1]) &
        ~(posicion_error_1_pi[0] ^ posicion_error_2_pi[0]);


    // ============================================================
    // ERROR 1
    // ============================================================

    assign mascara_error_1[0] =
        habilitar_errores_pi &
        ~posicion_error_1_pi[2] &
        ~posicion_error_1_pi[1] &
        ~posicion_error_1_pi[0];

    assign mascara_error_1[1] =
        habilitar_errores_pi &
        ~posicion_error_1_pi[2] &
        ~posicion_error_1_pi[1] &
         posicion_error_1_pi[0];

    assign mascara_error_1[2] =
        habilitar_errores_pi &
        ~posicion_error_1_pi[2] &
         posicion_error_1_pi[1] &
        ~posicion_error_1_pi[0];

    assign mascara_error_1[3] =
        habilitar_errores_pi &
        ~posicion_error_1_pi[2] &
         posicion_error_1_pi[1] &
         posicion_error_1_pi[0];

    assign mascara_error_1[4] =
        habilitar_errores_pi &
         posicion_error_1_pi[2] &
        ~posicion_error_1_pi[1] &
        ~posicion_error_1_pi[0];

    assign mascara_error_1[5] =
        habilitar_errores_pi &
         posicion_error_1_pi[2] &
        ~posicion_error_1_pi[1] &
         posicion_error_1_pi[0];

    assign mascara_error_1[6] =
        habilitar_errores_pi &
         posicion_error_1_pi[2] &
         posicion_error_1_pi[1] &
        ~posicion_error_1_pi[0];

    assign mascara_error_1[7] =
        habilitar_errores_pi &
         posicion_error_1_pi[2] &
         posicion_error_1_pi[1] &
         posicion_error_1_pi[0];


    // ============================================================
    // ERROR 2
    //
    // Solo se aplica cuando las posiciones son distintas.
    // Si son iguales tenemos solamente UN error.
    // ============================================================

    assign mascara_error_2[0] =
        habilitar_errores_pi & ~misma_posicion &
        ~posicion_error_2_pi[2] &
        ~posicion_error_2_pi[1] &
        ~posicion_error_2_pi[0];

    assign mascara_error_2[1] =
        habilitar_errores_pi & ~misma_posicion &
        ~posicion_error_2_pi[2] &
        ~posicion_error_2_pi[1] &
         posicion_error_2_pi[0];

    assign mascara_error_2[2] =
        habilitar_errores_pi & ~misma_posicion &
        ~posicion_error_2_pi[2] &
         posicion_error_2_pi[1] &
        ~posicion_error_2_pi[0];

    assign mascara_error_2[3] =
        habilitar_errores_pi & ~misma_posicion &
        ~posicion_error_2_pi[2] &
         posicion_error_2_pi[1] &
         posicion_error_2_pi[0];

    assign mascara_error_2[4] =
        habilitar_errores_pi & ~misma_posicion &
         posicion_error_2_pi[2] &
        ~posicion_error_2_pi[1] &
        ~posicion_error_2_pi[0];

    assign mascara_error_2[5] =
        habilitar_errores_pi & ~misma_posicion &
         posicion_error_2_pi[2] &
        ~posicion_error_2_pi[1] &
         posicion_error_2_pi[0];

    assign mascara_error_2[6] =
        habilitar_errores_pi & ~misma_posicion &
         posicion_error_2_pi[2] &
         posicion_error_2_pi[1] &
        ~posicion_error_2_pi[0];

    assign mascara_error_2[7] =
        habilitar_errores_pi & ~misma_posicion &
         posicion_error_2_pi[2] &
         posicion_error_2_pi[1] &
         posicion_error_2_pi[0];


    // ============================================================
    // INSERCIÓN
    // ============================================================

    assign palabra_error_po =
        palabra_pi ^
        mascara_error_1 ^
        mascara_error_2;

endmodule