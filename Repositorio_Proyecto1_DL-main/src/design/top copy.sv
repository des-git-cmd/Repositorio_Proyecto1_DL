module top (
    // Palabra codificada por el circuito fisico de XOR.
    // {PG, i3, i2, i1, c2, i0, c1, c0}
    input  logic [7:0] palabra_pi,

    // Control del inyector de errores.
    input  logic [2:0] posicion_error_1_pi,
    input  logic [2:0] posicion_error_2_pi,
    input  logic       habilitar_errores_pi,

    // DIP 8:
    // 1 = visualizar transmisor.
    // 0 = visualizar receptor.
    input  logic       modo_tx_pi,

    // En la prueba individual no se usa externamente.
    inout  wire [7:0]  enlace_io,

    output logic [5:0] led,
    output logic [6:0] seg,

    // Pin 81: display TX.
    output logic       habilitar_display_dato_po,

    // Pin 82: display RX.
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

    // Salida de M7:
    //
    // 0   = sin error
    // 1-7 = posicion Hamming
    // 8   = error en paridad global
    // D   = doble error
    logic [3:0] codigo_error_rx;

    // ============================================================
    // VISUALIZACION
    // ============================================================

    logic [3:0] valor_display;


    // ============================================================
    // RECUPERAR DATO ORIGINAL
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
        .palabra_pi            (palabra_pi),
        .posicion_error_1_pi   (posicion_error_1_pi),
        .posicion_error_2_pi   (posicion_error_2_pi),
        .habilitar_errores_pi  (habilitar_errores_pi),
        .palabra_error_po      (palabra_tx)
    );


    assign error_insertado =
        |(palabra_tx ^ palabra_pi);


    // ============================================================
    // PRUEBA INDIVIDUAL CON UNA SOLA FPGA
    //
    // La salida del transmisor entra directamente al receptor.
    // Esto permite probar SEC-DED sin otra Tang Nano.
    // ============================================================

    assign palabra_rx =
        palabra_tx;


    // El bus externo se mantiene libre en esta version.
    assign enlace_io =
        8'bzzzzzzzz;


    // ============================================================
    // M3 - SINDROME Y PARIDAD
    // ============================================================

    m3_calculador_sindrome calculador_sindrome (
        .palabra_pi               (palabra_rx),
        .sindrome_po              (sindrome_rx),
        .paridad_global_error_po  (paridad_global_error_rx)
    );


    // ============================================================
    // M4 - SEC / DED Y CORRECCION
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
    // M5 - RECUPERAR LOS CUATRO BITS
    // ============================================================

    m5_recuperador_dato recuperador (
        .palabra_corregida_pi  (palabra_corregida_rx),
        .dato_recuperado_po    (dato_rx)
    );


    // ============================================================
    // M7 - INDICADOR DE POSICION / TIPO DE ERROR
    // ============================================================

    m7_indicador_error indicador_error (
        .sindrome_pi              (sindrome_rx),
        .paridad_global_error_pi  (paridad_global_error_rx),
        .error_sec_pi             (error_sec_rx),
        .error_ded_pi             (error_ded_rx),
        .codigo_error_po          (codigo_error_rx)
    );


    // ============================================================
    // SELECCION DE LO QUE MUESTRA EL DISPLAY
    //
    // TX:
    //     muestra el dato original.
    //
    // RX:
    //     muestra la POSICION/TIPO DEL ERROR.
    // ============================================================

    assign valor_display =
        modo_tx_pi ? dato_tx : codigo_error_rx;


    // ============================================================
    // SELECCION DE DISPLAY FISICO
    // ============================================================

    assign habilitar_display_dato_po =
        modo_tx_pi;

    assign habilitar_display_error_po =
        ~modo_tx_pi;


    // ============================================================
    // M6 - 4 BITS A 7 SEGMENTOS
    // ============================================================

    m6_display_7segmentos display_compartido (
        .dato_pi (valor_display),
        .seg_po  (seg)
    );


    // ============================================================
    // LED 0-3
    //
    // IMPORTANTE:
    // Los LED NO muestran codigo_error_rx.
    //
    // TX -> muestran dato_tx.
    // RX -> muestran dato_rx ya procesado por el receptor.
    //
    // De esta forma en RX podemos ver simultaneamente:
    //
    // LED     = dato recuperado
    // Display = posicion del error
    // ============================================================

    assign led[0] =
        ~(modo_tx_pi ? dato_tx[3] : dato_rx[3]);

    assign led[1] =
        ~(modo_tx_pi ? dato_tx[2] : dato_rx[2]);

    assign led[2] =
        ~(modo_tx_pi ? dato_tx[1] : dato_rx[1]);

    assign led[3] =
        ~(modo_tx_pi ? dato_tx[0] : dato_rx[0]);


    // ============================================================
    // LED 4
    //
    // TX -> se inserto al menos un error.
    // RX -> SEC: error sencillo detectado/corregido.
    // ============================================================

    assign led[4] =
        ~(modo_tx_pi ? error_insertado : error_sec_rx);


    // ============================================================
    // LED 5
    //
    // TX -> comprobacion de paridad global.
    // RX -> DED: doble error detectado.
    // ============================================================

    assign led[5] =
        modo_tx_pi ? (^palabra_pi) : ~error_ded_rx;


endmodule