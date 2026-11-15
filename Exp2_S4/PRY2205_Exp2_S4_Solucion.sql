/* =============================================================================
   PRY2205 - Consulta de Bases de Datos
   Experiencia 2 - Semana 4: "Desarrollando JOINS en las tablas"
   Caso: Conciertos Chile S.A.
   Usuario: PRY2205_S4
   -----------------------------------------------------------------------------
   Contenido:
      Caso 1 : Listado de Trabajadores
      Caso 2 : Listado de Cajeros
      Caso 3 : Listado de Bonificaciones
   Observaciones:
      - No se utiliza la clausula WITH.
      - Todos los valores monetarios se muestran REDONDEADOS a enteros.
      - No se usan fechas fijas: la fecha de ejecucion se obtiene con SYSDATE.
   ============================================================================= */


/* ---- CONFIGURACION DE SESION (formato de fecha y separadores numericos) ---- */
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ',.';


/* =============================================================================
   CASO 1: LISTADO DE TRABAJADORES
   -----------------------------------------------------------------------------
   Lista a los trabajadores cuyo sueldo base se encuentra entre $650.000 y
   $3.000.000, mostrando nombre completo, RUT con formato, tipo de trabajador,
   ciudad y sueldo base.
   Ordenado por nombre de ciudad descendente y sueldo base ascendente.
   ============================================================================= */

SELECT UPPER(t.nombre
             || ' '
             || t.appaterno
             || ' '
             || t.apmaterno)                        AS "Nombre Completo Trabajador",
       TO_CHAR(t.numrut, 'FM99G999G999')
       || '-'
       || UPPER(t.dvrut)                            AS "RUT Trabajador",
       UPPER(NVL(tt.desc_categoria, 'SIN CATEGORIA')) AS "Tipo Trabajador",
       UPPER(NVL(cc.nombre_ciudad, 'SIN CIUDAD'))   AS "Ciudad Trabajador",
       TO_CHAR(ROUND(t.sueldo_base), '$999G999G999') AS "Sueldo Base"
  FROM trabajador      t
  LEFT JOIN tipo_trabajador tt ON t.id_categoria_t = tt.id_categoria
  LEFT JOIN comuna_ciudad   cc ON t.id_ciudad      = cc.id_ciudad
 WHERE t.sueldo_base BETWEEN 650000 AND 3000000
 ORDER BY UPPER(NVL(cc.nombre_ciudad, 'SIN CIUDAD')) DESC,
          t.sueldo_base ASC;


/* =============================================================================
   CASO 2: LISTADO DE CAJEROS
   -----------------------------------------------------------------------------
   Bitacora de ventas por trabajador con rol CAJERO: cantidad de tickets
   vendidos, total vendido, comision total, tipo de trabajador y comuna.
   Solo se consideran los cajeros cuya suma de montos de tickets supera $50.000.
   Ordenado por el total vendido de forma descendente.
   ============================================================================= */

SELECT TO_CHAR(t.numrut, 'FM99G999G999')
       || '-'
       || UPPER(t.dvrut)                                AS "RUT Trabajador",
       INITCAP(t.nombre)
       || ' '
       || UPPER(t.appaterno)                            AS "Nombre Trabajador",
       COUNT(tc.nro_ticket)                             AS "Total Tickets",
       TO_CHAR(ROUND(SUM(tc.monto_ticket)), '$999G999G999')        AS "Total Vendido",
       TO_CHAR(ROUND(SUM(NVL(ct.valor_comision, 0))), '$999G999G999') AS "Comisión Total",
       UPPER(tt.desc_categoria)                         AS "Tipo Trabajador",
       UPPER(NVL(cc.nombre_ciudad, 'SIN CIUDAD'))       AS "Ciudad Trabajador"
  FROM trabajador        t
  JOIN tipo_trabajador   tt ON t.id_categoria_t = tt.id_categoria
  JOIN tickets_concierto tc ON tc.numrut_t      = t.numrut
  LEFT JOIN comisiones_ticket ct ON ct.nro_ticket = tc.nro_ticket
  LEFT JOIN comuna_ciudad     cc ON cc.id_ciudad  = t.id_ciudad
 WHERE UPPER(tt.desc_categoria) = 'CAJERO'
 GROUP BY t.numrut,
          t.dvrut,
          t.nombre,
          t.appaterno,
          tt.desc_categoria,
          cc.nombre_ciudad
HAVING SUM(tc.monto_ticket) > 50000
 ORDER BY SUM(tc.monto_ticket) DESC;


/* =============================================================================
   CASO 3: LISTADO DE BONIFICACIONES
   -----------------------------------------------------------------------------
   Para cada trabajador: anio de ingreso, anios de antiguedad, numero de cargas
   familiares, sistema de salud, sueldo base, bono FONASA, bono por antiguedad,
   AFP y estado civil vigente.

   Reglas de negocio:
      - Bono FONASA     : 1% del sueldo base si el sistema de salud es FONASA,
                          en caso contrario no se asigna bono extra (0).
      - Bono Antiguedad : 10% del sueldo base si tiene 10 o menos anios
                          trabajados; 15% si tiene 11 o mas anios.
      - Solo se consideran los trabajadores cuyo estado civil no tiene fecha de
        termino, o cuya fecha de termino es posterior a la fecha de ejecucion.

   Ordenado por RUT de forma ascendente.
   ============================================================================= */

SELECT TO_CHAR(t.numrut, 'FM99G999G999')                    AS "RUT Trabajador",
       INITCAP(t.nombre)
       || ' '
       || INITCAP(t.appaterno)                              AS "Trabajador Nombre",
       EXTRACT(YEAR FROM t.fecing)                          AS "Año Ingreso",
       EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing) AS "Años Antigüedad",
       COUNT(af.numrut_carga)                               AS "Num. Cargas Familiares",
       INITCAP(i.nombre_isapre)                             AS "Nombre Isapre",
       TO_CHAR(ROUND(t.sueldo_base), '$999G999G999')        AS "Sueldo Base",
       CASE
           WHEN UPPER(i.nombre_isapre) = 'FONASA'
               THEN TO_CHAR(ROUND(t.sueldo_base * 0.01), '$999G999G999')
           ELSE TO_CHAR(0, '999G999G999')
       END                                                  AS "Bono Fonasa",
       CASE
           WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing) <= 10
               THEN TO_CHAR(ROUND(t.sueldo_base * 0.10), '$999G999G999')
           ELSE TO_CHAR(ROUND(t.sueldo_base * 0.15), '$999G999G999')
       END                                                  AS "Bono Antigüedad",
       INITCAP(a.nombre_afp)                                AS "Nombre AFP",
       UPPER(ecd.desc_estcivil)                             AS "Estado Civil"
  FROM trabajador   t
  JOIN isapre       i   ON i.cod_isapre      = t.cod_isapre
  JOIN afp          a   ON a.cod_afp         = t.cod_afp
  JOIN est_civil    ec  ON ec.numrut_t       = t.numrut
  JOIN estado_civil ecd ON ecd.id_estcivil   = ec.id_estcivil_est
  LEFT JOIN asignacion_familiar af ON af.numrut_t = t.numrut
 WHERE ec.fecter_estcivil IS NULL
    OR ec.fecter_estcivil > SYSDATE
 GROUP BY t.numrut,
          t.nombre,
          t.appaterno,
          t.fecing,
          t.sueldo_base,
          i.nombre_isapre,
          a.nombre_afp,
          ecd.desc_estcivil
 ORDER BY t.numrut ASC;
