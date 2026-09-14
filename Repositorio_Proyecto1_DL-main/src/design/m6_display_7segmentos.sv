module m6_display_7segmentos (
    input  logic [3:0] dato_pi,
    output logic [6:0] seg_po
);

    logic x3;
    logic x2;
    logic x1;
    logic x0;

    assign x3 = dato_pi[3];
    assign x2 = dato_pi[2];
    assign x1 = dato_pi[1];
    assign x0 = dato_pi[0];

    // C-391E: cátodo común
    // 1 = segmento encendido
    //
    // seg_po[0] = A
    // seg_po[1] = B
    // seg_po[2] = C
    // seg_po[3] = D
    // seg_po[4] = E
    // seg_po[5] = F
    // seg_po[6] = G

    // A
    assign seg_po[0] =
          (x1 & x2)
        | (x1 & ~x3)
        | (x3 & ~x0)
        | (~x0 & ~x2)
        | (x0 & x2 & ~x3)
        | (x3 & ~x1 & ~x2);

    // B
    assign seg_po[1] =
          (~x0 & ~x2)
        | (~x1 & ~x2)
        | (x0 & x1 & ~x3)
        | (x0 & x3 & ~x1)
        | (~x0 & ~x1 & ~x3);

    // C
    assign seg_po[2] =
          (x0 & ~x1)
        | (x0 & ~x2)
        | (x2 & ~x3)
        | (x3 & ~x2)
        | (~x1 & ~x2);

    // D
    assign seg_po[3] =
          (x3 & ~x1)
        | (x0 & x1 & ~x2)
        | (x0 & x2 & ~x1)
        | (x1 & x2 & ~x0)
        | (~x0 & ~x2 & ~x3);

    // E
    assign seg_po[4] =
          (x1 & x3)
        | (x2 & x3)
        | (x1 & ~x0)
        | (~x0 & ~x2);

    // F
    assign seg_po[5] =
          (x1 & x3)
        | (x2 & ~x0)
        | (x3 & ~x2)
        | (~x0 & ~x1)
        | (x2 & ~x1 & ~x3);

    // G
    assign seg_po[6] =
          (x0 & x3)
        | (x1 & ~x0)
        | (x1 & ~x2)
        | (x3 & ~x2)
        | (x2 & ~x1 & ~x3);

endmodule