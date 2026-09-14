module top (
    input  wire clk,

    input  wire btn1,
    input  wire btn2,

    output wire fila1,

    input  wire col1,
    input  wire col2,
    input  wire col3,
    input  wire col4,

    output wire [5:0] led,
    output wire [6:0] seg
);

    // ============================================================
    // FILA DEL TECLADO
    // ============================================================

    // Solamente utilizamos la primera fila.
    // Siempre permanece activa.

    assign fila1 = 1'b1;


    // ============================================================
    // SINCRONIZACIÓN DE LAS COLUMNAS
    // ============================================================

    reg [3:0] columnas_sync1 = 4'b0000;
    reg [3:0] columnas_sync2 = 4'b0000;

    always @(posedge clk) begin

        columnas_sync1 <= {col4, col3, col2, col1};
        columnas_sync2 <= columnas_sync1;

    end


    // ============================================================
    // GENERAR UNA LECTURA CADA 1 ms
    // ============================================================

    reg [14:0] contador_ms = 15'd0;

    wire tick_ms;

    assign tick_ms = (contador_ms == 15'd26999);

    always @(posedge clk) begin

        if (tick_ms)
            contador_ms <= 15'd0;
        else
            contador_ms <= contador_ms + 1'b1;

    end


    // ============================================================
    // ANTIRREBOTE
    // ============================================================

    reg [3:0] estado_estable = 4'b0000;

    reg [3:0] contador_col1 = 4'd0;
    reg [3:0] contador_col2 = 4'd0;
    reg [3:0] contador_col3 = 4'd0;
    reg [3:0] contador_col4 = 4'd0;


    // ============================================================
    // PALABRA DE CUATRO BITS
    // ============================================================

    reg [3:0] dato = 4'b0000;

    reg confirmado = 1'b0;


    // ============================================================
    // CONTROL DE LAS TECLAS
    // ============================================================

    always @(posedge clk) begin

        // --------------------------------------------------------
        // BTN2 = BORRAR
        // --------------------------------------------------------

        if (btn2 == 1'b0) begin

            dato <= 4'b0000;
            confirmado <= 1'b0;

            estado_estable <= 4'b0000;

            contador_col1 <= 4'd0;
            contador_col2 <= 4'd0;
            contador_col3 <= 4'd0;
            contador_col4 <= 4'd0;

        end

        else begin

            // ----------------------------------------------------
            // BTN1 = CONFIRMAR
            // ----------------------------------------------------

            if (btn1 == 1'b0)
                confirmado <= 1'b1;


            // ----------------------------------------------------
            // LEER TECLADO CADA 1 ms
            // ----------------------------------------------------

            if (tick_ms) begin


                // =================================================
                // TECLA 1
                // controla dato[3]
                // =================================================

                if (columnas_sync2[0] == estado_estable[0]) begin

                    contador_col1 <= 4'd0;

                end

                else begin

                    if (contador_col1 == 4'd7) begin

                        estado_estable[0] <= columnas_sync2[0];
                        contador_col1 <= 4'd0;

                        // Solo actuar cuando la tecla se PRESIONA,
                        // no cuando se suelta.

                        if ((columnas_sync2[0] == 1'b1) &&
                            (confirmado == 1'b0)) begin

                            dato[3] <= ~dato[3];

                        end

                    end

                    else begin

                        contador_col1 <= contador_col1 + 1'b1;

                    end

                end


                // =================================================
                // TECLA 2
                // controla dato[2]
                // =================================================

                if (columnas_sync2[1] == estado_estable[1]) begin

                    contador_col2 <= 4'd0;

                end

                else begin

                    if (contador_col2 == 4'd7) begin

                        estado_estable[1] <= columnas_sync2[1];
                        contador_col2 <= 4'd0;

                        if ((columnas_sync2[1] == 1'b1) &&
                            (confirmado == 1'b0)) begin

                            dato[2] <= ~dato[2];

                        end

                    end

                    else begin

                        contador_col2 <= contador_col2 + 1'b1;

                    end

                end


                // =================================================
                // TECLA 3
                // controla dato[1]
                // =================================================

                if (columnas_sync2[2] == estado_estable[2]) begin

                    contador_col3 <= 4'd0;

                end

                else begin

                    if (contador_col3 == 4'd7) begin

                        estado_estable[2] <= columnas_sync2[2];
                        contador_col3 <= 4'd0;

                        if ((columnas_sync2[2] == 1'b1) &&
                            (confirmado == 1'b0)) begin

                            dato[1] <= ~dato[1];

                        end

                    end

                    else begin

                        contador_col3 <= contador_col3 + 1'b1;

                    end

                end


                // =================================================
                // TECLA A
                // controla dato[0]
                // =================================================

                if (columnas_sync2[3] == estado_estable[3]) begin

                    contador_col4 <= 4'd0;

                end

                else begin

                    if (contador_col4 == 4'd7) begin

                        estado_estable[3] <= columnas_sync2[3];
                        contador_col4 <= 4'd0;

                        if ((columnas_sync2[3] == 1'b1) &&
                            (confirmado == 1'b0)) begin

                            dato[0] <= ~dato[0];

                        end

                    end

                    else begin

                        contador_col4 <= contador_col4 + 1'b1;

                    end

                end

            end

        end

    end


    // ============================================================
    // LEDs
    // ============================================================

    // Activos en bajo.

    assign led[0] = ~dato[3];
    assign led[1] = ~dato[2];
    assign led[2] = ~dato[1];
    assign led[3] = ~dato[0];

    // LED 5 sin utilizar.
    assign led[4] = 1'b1;

    // LED 6 = confirmado.
    assign led[5] = ~confirmado;

// ============================================================
// DECODIFICADOR HEXADECIMAL A 7 SEGMENTOS
//
// dato[3] = bit más significativo
// dato[0] = bit menos significativo
//
// seg[0] = A
// seg[1] = B
// seg[2] = C
// seg[3] = D
// seg[4] = E
// seg[5] = F
// seg[6] = G
//
// C-391E: cátodo común
// 1 = segmento encendido
// ============================================================

wire x3;
wire x2;
wire x1;
wire x0;

assign x3 = dato[3];
assign x2 = dato[2];
assign x1 = dato[1];
assign x0 = dato[0];


// Segmento A
assign seg[0] =
      (x1 & x2)
    | (x1 & ~x3)
    | (x3 & ~x0)
    | (~x0 & ~x2)
    | (x0 & x2 & ~x3)
    | (x3 & ~x1 & ~x2);


// Segmento B
assign seg[1] =
      (~x0 & ~x2)
    | (~x1 & ~x2)
    | (x0 & x1 & ~x3)
    | (x0 & x3 & ~x1)
    | (~x0 & ~x1 & ~x3);


// Segmento C
assign seg[2] =
      (x0 & ~x1)
    | (x0 & ~x2)
    | (x2 & ~x3)
    | (x3 & ~x2)
    | (~x1 & ~x2);


// Segmento D
assign seg[3] =
      (x3 & ~x1)
    | (x0 & x1 & ~x2)
    | (x0 & x2 & ~x1)
    | (x1 & x2 & ~x0)
    | (~x0 & ~x2 & ~x3);


// Segmento E
assign seg[4] =
      (x1 & x3)
    | (x2 & x3)
    | (x1 & ~x0)
    | (~x0 & ~x2);


// Segmento F
assign seg[5] =
      (x1 & x3)
    | (x2 & ~x0)
    | (x3 & ~x2)
    | (~x0 & ~x1)
    | (x2 & ~x1 & ~x3);


// Segmento G
assign seg[6] =
      (x0 & x3)
    | (x1 & ~x0)
    | (x1 & ~x2)
    | (x3 & ~x2)
    | (x2 & ~x1 & ~x3);


endmodule