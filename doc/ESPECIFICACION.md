# Especificación del proyecto Hamming SEC-DED

## 1. Plataforma y herramientas

- FPGA: Tang Nano 9K.
- Lenguaje: SystemVerilog.
- Simulación y síntesis: OSS CAD Suite.
- Editor: Visual Studio Code.
- Control de versiones: Git y GitHub.
- Sistema operativo: Windows con PowerShell.

## 2. Organización del repositorio

| Ruta | Contenido |
|---|---|
| `doc/` | Documentación y datasheets |
| `src/build/` | Archivos generados |
| `src/constr/` | Restricciones de pines `.cst` |
| `src/design/` | Módulos SystemVerilog |
| `src/sim/` | Testbenches |

## 3. Distribución de los datos

La entrada original es `dato[3:0] = {i3, i2, i1, i0}`.

La palabra Hamming se organiza como:

`hamming[6:0] = {i3, i2, i1, c2, i0, c1, c0}`

La palabra transmitida es:

`palabra[7:0] = {paridad_global, hamming[6:0]}`

La paridad global ocupa el bit más significativo: `palabra[7]`.

## 4. Codificación Hamming (7,4)

Se utiliza paridad par:

- `c2 = i3 XOR i2 XOR i1`
- `c1 = i3 XOR i2 XOR i0`
- `c0 = i3 XOR i1 XOR i0`

| Posición Hamming | Índice SystemVerilog | Señal |
|---:|---:|---|
| 1 | 0 | c0 |
| 2 | 1 | c1 |
| 3 | 2 | i0 |
| 4 | 3 | c2 |
| 5 | 4 | i1 |
| 6 | 5 | i2 |
| 7 | 6 | i3 |
| Global | 7 | paridad_global |

## 5. Paridad global

La paridad global es par y se calcula sobre los siete bits Hamming:

`paridad_global = XOR de hamming[6:0]`

Este bit permite diferenciar un error sencillo de un error doble.

## 6. Generador de errores

Se utilizan dos selectores de tres bits:

- `posicion_error_1[2:0]`
- `posicion_error_2[2:0]`

Cada selector representa directamente un índice entre 0 y 7. Cada error tiene una señal independiente:

- `habilitar_error_1`
- `habilitar_error_2`

La operación general es:

`palabra_tx = palabra_codificada XOR mascara_error_1 XOR mascara_error_2`

- Habilitación en 0: no se inserta ese error.
- Habilitación en 1: se invierte el bit seleccionado.
- Si ambos errores seleccionan la misma posición, las dos inversiones se cancelan.

## 7. Síndrome

El receptor calcula:

- `s0 = r0 XOR r2 XOR r4 XOR r6`
- `s1 = r1 XOR r2 XOR r5 XOR r6`
- `s2 = r3 XOR r4 XOR r5 XOR r6`

La salida es `sindrome[2:0] = {s2, s1, s0}`.

Un síndrome entre `001` y `111` representa las posiciones Hamming 1 a 7. Para convertirlo en índice SystemVerilog se utiliza `indice_error = sindrome - 1`.

## 8. Clasificación SEC-DED

| Paridad global | Síndrome | Resultado | Acción |
|---:|---:|---|---|
| 0 | 000 | Sin error | No modificar |
| 1 | 001 a 111 | Error sencillo | Corregir |
| 1 | 000 | Error en paridad global | Los datos Hamming son válidos |
| 0 | 001 a 111 | Error doble | Detectar y no corregir |

## 9. División entre CMOS y FPGA

### Circuitos 74HC

- Codificador Hamming.
- Generador de paridad global.
- Verificador de paridad global.
- Generador de síndrome.
- Oscilador en anillo con 74HC04.

### FPGA

- Visualización hexadecimal.
- Generador de uno o dos errores.
- Clasificador SEC-DED.
- Corrector del error sencillo.
- Recuperación de los cuatro bits.
- Control de LED y displays.

## 10. Indicadores

Distribución propuesta de los LED integrados:

- `LED[3:0]`: dato recuperado.
- `LED[4]`: error sencillo corregido.
- `LED[5]`: error doble detectado.

La posición del error se muestra mediante el síndrome en los displays.

## 11. Displays

Se utilizan dos displays de siete segmentos de ánodo común. Según el enunciado, ambos comparten las líneas de segmentos y muestran el mismo dato seleccionado:

- Dato recibido en hexadecimal.
- Posición del error o síndrome en hexadecimal.

La selección se realiza mediante un interruptor.

## 12. Reglas eléctricas

- Los circuitos externos trabajan a 3.3 V.
- Todos los bloques comparten GND.
- Se utilizan circuitos CMOS de la familia 74HC.
- No se dejan entradas CMOS flotantes.
- Cada integrado utiliza un capacitor de desacoplo de 100 nF.
- Los LED y displays utilizan resistencias limitadoras.
- Se evitan los pines de 1.8 V y los pines especiales.
- Los pines se definen posteriormente en el archivo `.cst`.
- Se utiliza `PULL_MODE=DOWN` solamente en pines compatibles.

## 13. Reglas del código

- Los módulos utilizan nombres numerados: `m1_`, `m2_`, etc.
- Los testbenches se guardan en `src/sim`.
- Los módulos se guardan en `src/design`.
- Los comentarios son breves y están escritos en español.
- Se utilizan ecuaciones booleanas en los bloques exigidos.
- No se emplean construcciones avanzadas de SystemVerilog.
- Cada subsistema tendrá pruebas RTL y posteriormente pruebas post-síntesis.
