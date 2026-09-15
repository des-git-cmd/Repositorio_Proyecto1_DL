module top (
    // ============================================================
    // PALABRA GENERADA POR EL HAMMING FÍSICO
    // {PG, i3, i2, i1, c2, i0, c1, c0}
    // ============================================================
    input  logic [7:0] palabra_pi,

    // ============================================================
    // DIP DE 8 POSICIONES
    // SW1-SW3 -> posición error 1
    // SW4-SW6 -> posición error 2
    // SW7     -> habilitar errores
    // SW8     -> modo TX/RX
    // ============================================================
    input  logic [2:0] posicion_error_1_pi,
    input  logic [2:0] posicion_error_2_pi,

    input  logic       habilitar_errores_pi,
    input  logic       modo_tx_pi,

    // ============================================================
    // BUS ENTRE LAS DOS FPGA
    // ============================================================
    inout wire [7:0] enlace_io,

    // ============================================================
    // SALIDAS
    // ============================================================
      input  logic       seleccionar_error_pi,

    output logic [5:0] led,
    output logic [6:0] seg,

    output logic       habilitar_display_dato_po,
    output logic       habilitar_display_error_po
);


    // ============================================================
    // TRANSMISOR
    // ============================================================

    logic [3:0] dato_tx;


    logic [7:0] palabra_tx;

    logic       error_insertado;


    // ============================================================
    // RECEPTOR
    // ============================================================

    logic [7:0] palabra_rx;

    logic [2:0] sindrome_rx;
    logic       paridad_global_error_rx;

    logic [7:0] palabra_corregida_rx;

    logic       error_sec_rx;
    logic       error_ded_rx;

    logic [3:0] dato_rx;

    // Código que luego irá al segundo display:
    //
    // 0 = sin error
    // 1-7 = posición Hamming
    // 8 = error en paridad global
    // D = doble error
    logic [3:0] codigo_error_rx;


    // ============================================================
    // VISUALIZACIÓN
    // ============================================================

    logic [3:0] dato_mostrar;

    logic [3:0] valor_display;


    // ============================================================
    // RECUPERAR DATO ORIGINAL DEL TRANSMISOR
    // ============================================================

    assign dato_tx = {
        palabra_pi[6],
        palabra_pi[5],
        palabra_pi[4],
        palabra_pi[2]
    };



    // ============================================================
    // M2 - INYECTOR DE ERRORES
    // ============================================================

    m2_inyector_errores inyector (
        .palabra_pi           (palabra_pi),
        .posicion_error_1_pi  (posicion_error_1_pi),
        .posicion_error_2_pi  (posicion_error_2_pi),
        .habilitar_errores_pi (habilitar_errores_pi),
        .palabra_error_po     (palabra_tx)
    );


    // ============================================================
    // INDICAR SI SE INSERTÓ UN ERROR
    // ============================================================

    assign error_insertado =
        |(palabra_tx ^ palabra_pi);


    // ============================================================
    // ENLACE TX / RX
    //
    // SW8 = 1 -> transmite
    // SW8 = 0 -> recibe
    // ============================================================

    // Prueba individual: el receptor recibe internamente
    // la palabra física después del inyector de errores.
    assign palabra_rx = palabra_tx;

    // Bus externo deshabilitado durante esta prueba.
    assign enlace_io = 8'bzzzzzzzz;


    // ============================================================
    // M3 - SÍNDROME Y PARIDAD
    // ============================================================

    m3_calculador_sindrome calculador_sindrome (
        .palabra_pi               (palabra_rx),
        .sindrome_po              (sindrome_rx),
        .paridad_global_error_po  (paridad_global_error_rx)
    );


    // ============================================================
    // M4 - SEC / DED + CORRECCIÓN
    // ============================================================

    m4_decodificador_secded corrector (
        .palabra_pi               (palabra_rx),
        .sindrome_pi              (sindrome_rx),
        .paridad_global_error_pi  (paridad_global_error_rx),

        .palabra_corregida_po     (palabra_corregida_rx),
        .error_sec_po             (error_sec_rx),
        .error_ded_po             (error_ded_rx)
    );


    // ============================================================
    // M5 - RECUPERAR DATO
    // ============================================================

    m5_recuperador_dato recuperador (
        .palabra_corregida_pi (palabra_corregida_rx),
        .dato_recuperado_po   (dato_rx)
    );


    // ============================================================
    // M7 - POSICIÓN / TIPO DE ERROR
    // ============================================================

    m7_indicador_error indicador_error (
        .sindrome_pi              (sindrome_rx),
        .paridad_global_error_pi  (paridad_global_error_rx),
        .error_sec_pi             (error_sec_rx),
        .error_ded_pi             (error_ded_rx),
        .codigo_error_po          (codigo_error_rx)
    );


    // ============================================================
    // DATO A MOSTRAR EN EL DISPLAY ACTUAL
    //
    // TX -> dato original
    // RX -> dato recuperado
    // ============================================================

    assign dato_mostrar =
        modo_tx_pi ? dato_tx : dato_rx;


    // ============================================================
    // M6 - DISPLAY HEXADECIMAL ACTUAL
    // ============================================================

        // Selector = 0: dato.
    // Selector = 1: posición/tipo de error.
    // Multiplexor expresado con operaciones booleanas.
    assign valor_display =
        (dato_mostrar    & {4{~seleccionar_error_pi}}) |
        (codigo_error_rx & {4{ seleccionar_error_pi}});

    // Un solo display habilitado a la vez.
    // Nivel alto activa el transistor NPN correspondiente.
    assign habilitar_display_dato_po =
        ~seleccionar_error_pi;

    assign habilitar_display_error_po =
        seleccionar_error_pi;

    // Las siete líneas se compartirán entre ambos displays.
    m6_display_7segmentos display_compartido (
        .dato_pi (valor_display),
        .seg_po  (seg)
    );
    


    // ============================================================
    // LED 0-3
    //
    // TX -> dato original
    // RX -> dato corregido
    // ============================================================

    assign led[0] = ~dato_mostrar[3];
    assign led[1] = ~dato_mostrar[2];
    assign led[2] = ~dato_mostrar[1];
    assign led[3] = ~dato_mostrar[0];


    // ============================================================
    // LED 4
    //
    // TX -> error insertado
    // RX -> error sencillo SEC
    // ============================================================

    assign led[4] =
        ~(modo_tx_pi ? error_insertado : error_sec_rx);


    // TX: paridad global par -> LED encendido.
    // RX: error doble detectado -> LED encendido.
    assign led[5] =
        modo_tx_pi ? (^palabra_pi) : ~error_ded_rx;


endmodule