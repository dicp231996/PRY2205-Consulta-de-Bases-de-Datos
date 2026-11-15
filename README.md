# PRY2205 - Consulta de Bases de Datos

Actividades del ramo **Consulta de Bases de Datos** (PRY2205) - Duoc UC.

## Experiencia 2 - Semana 4: Desarrollando JOINS en las tablas

Caso: **Conciertos Chile S.A.**

Script de entrega: [`Exp2_S4/PRY2205_Exp2_S4_Solucion.sql`](Exp2_S4/PRY2205_Exp2_S4_Solucion.sql)

El script resuelve los tres casos del encargo:

| Caso | Requerimiento | Filas |
|------|---------------|-------|
| 1 | Listado de trabajadores con sueldo base entre $650.000 y $3.000.000 | 20 |
| 2 | Listado de cajeros: tickets vendidos, total vendido y comision total | 5 |
| 3 | Listado de bonificaciones: bono FONASA y bono por antiguedad | 23 |

### Consideraciones tecnicas

- No se utiliza la clausula WITH, segun lo exigido en el enunciado.
- Los montos se muestran redondeados a enteros con formato `$9.999.999`.
- La antiguedad se calcula con `SYSDATE`, sin fechas fijas, por lo que el valor
  cambia segun el anio en que se ejecute el reporte.
- El script fija `NLS_DATE_FORMAT` y `NLS_NUMERIC_CHARACTERS` al inicio para que
  los formatos de fecha y de miles coincidan con los exigidos.

### Como ejecutarlo

1. Conectado como `SYS` o `SYSTEM`, ejecutar `PRY2205_Exp2_S4_Script_crea_usuario.sql`
   (crea el usuario `PRY2205_S4`).
2. Crear la conexion `PRY2205_ACTIVIDAD_S4` con ese usuario.
3. Con esa conexion, ejecutar `PRY2205_Exp2_S4_CreaEsquemaPoblado.sql`.
4. Ejecutar `Exp2_S4/PRY2205_Exp2_S4_Solucion.sql`.

Probado en Oracle Database 19c con Oracle SQL Developer.

### Integrantes

- dicp231996
- _(pendiente: agregar compañero/a de la pareja)_
