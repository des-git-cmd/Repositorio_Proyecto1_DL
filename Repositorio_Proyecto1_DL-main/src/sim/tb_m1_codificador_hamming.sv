`timescale 1ns/1ps

module tb_m1_codificador_hamming;

    logic [3:0] dato;
    logic [6:0] hamming;
    logic [6:0] esperado;

    // Modelo digital del codificador físico.
    // Este módulo se usa únicamente en simulación.
    m1_codificador_hamming dut (
        .dato_pi    (dato),
        .hamming_po (hamming)
    );

    initial begin
        for (int n = 0; n < 16; n++) begin
            dato = n;

            // {i3, i2, i1, c2, i0, c1, c0}
            esperado = {
                dato[3],
                dato[2],
                dato[1],
                (dato[3] ^ dato[2] ^ dato[1]),
                dato[0],
                (dato[3] ^ dato[2] ^ dato[0]),
                (dato[3] ^ dato[1] ^ dato[0])
            };

            #1;

            if (hamming !== esperado)
                $fatal(1,
                    "FALLO: dato=%b esperado=%b obtenido=%b",
                    dato, esperado, hamming);

            $display("OK: dato=%b Hamming=%b PG=%b",
                     dato, hamming, ^hamming);
        end

        $display("HAMMING: 16 DE 16 PRUEBAS CORRECTAS");
        $finish;
    end

endmodule