-- En este archivo se resolverán los ejercicios correspondientes al práctico I

-- 1. Muestre el apellido, nombre, las horas aportadas y la fecha de nacimiento de todos los voluntarios cuya tarea sea IT_PROG o ST_CLERK y cuyas horas aportadas no superen 7.000. Ordene por apellido y nombre.
SELECT apellido, nombre, horas_aportadas, fecha_nacimiento, id_tarea
FROM voluntario
WHERE (id_tarea = 'IT_PROG' OR id_tarea = 'ST_CLERK') AND (horas_aportadas < 7000)
ORDER BY apellido;

-- 2. Genere un listado ordenado por número de voluntario, incluyendo también el nombre y apellido y el e-mail de los voluntarios con menos de 10000 horas aportadas. Coloque como encabezado de las columnas los títulos ‘Numero’, 'Nombre y apellido' y 'Contacto'
SELECT nro_voluntario AS "Número" , nombre || ', ' || apellido AS "Nombre y apellido", e_mail AS "Contacto"
FROM voluntario 
WHERE horas_aportadas < 10000
ORDER BY nro_voluntario;

-- 3. Genere un listado de los distintos id de coordinadores en la base de Voluntariado. Tenga en cuenta de no incluir el valor nulo en el resultado.
SELECT DISTINCT id_coordinador
FROM voluntario
WHERE id_coordinador IS NOT NULL;

-- 4. Muestre los códigos de las diferentes tareas que están desarrollando los voluntarios que no registran porcentaje de donación.
SELECT DISTINCT id_tarea
FROM voluntario 
WHERE porcentaje IS NULL;

-- 5. Muestre los 5 voluntarios que poseen más horas aportadas y que hayan nacido después del año 1995
SELECT horas_aportadas, fecha_nacimiento
FROM voluntario
WHERE EXTRACT(year from fecha_nacimiento) > 1995
ORDER BY horas_aportadas DESC
LIMIT 5;

-- 6. Liste el id, apellido, nombre y edad de los voluntarios de entre 40 y 50 años, con fecha de cumpleaños en el mes actual. Limite el resultado a los 3 voluntarios de mayor edad.
SELECT nro_voluntario, apellido, nombre, EXTRACT(year from current_date) - EXTRACT(year from fecha_nacimiento) AS "edad"
FROM voluntario
WHERE ((EXTRACT(year from current_date) - EXTRACT(year from fecha_nacimiento)) BETWEEN 40 AND 50) AND 
        EXTRACT(month from current_date) = EXTRACT(month from fecha_nacimiento)
ORDER BY EXTRACT(year from current_date) - EXTRACT(year from fecha_nacimiento)
LIMIT 3;

-- En algunos motores PostgreSQL se puede hacer los siguiente:
SELECT nro_voluntario, apellido, nombre, EXTRACT(year from current_date) - EXTRACT(year from fecha_nacimiento) AS "edad"
FROM voluntario
WHERE (edad BETWEEN 40 AND 50) AND (EXTRACT(month from current_date) = EXTRACT(month from fecha_nacimiento))
ORDER BY edad
LIMIT 3;

-- 7. Encuentre la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios de más de 30 años
SELECT MIN(horas_aportadas), MAX(horas_aportadas), AVG(horas_aportadas)
FROM voluntario
WHERE EXTRACT(year from current_date) - EXTRACT(year from fecha_nacimiento) > 30;

-- 8. Por cada institución con identificador conocido, indicar la cantidad de voluntarios que trabajan en ella y el total de horas que aportan.
SELECT COUNT(nro_voluntario), SUM(horas_aportadas)
FROM voluntario
GROUP BY id_institucion; 
-- Por ejemplo: En la tabla resultante nos figura que una sola persona trabaja para la institución 190 y aporta 3468.00 horas. En efecto, María es la única que labura para la institución 190 y aporta 3468.00 horas para esa instiyución.

-- 9. Muestre el identificador de las instituciones y la cantidad de voluntarios que trabajan en cada una de ellas, sólo de aquellas instituciones que tengan más de 10 voluntarios.
SELECT id_institucion, COUNT(nro_voluntario) AS cantidad_laburantes
FROM voluntario
GROUP BY id_institucion
HAVING COUNT(nro_voluntario) > 10;

-- 10. Liste los coordinadores que tienen a su cargo más de 3 voluntarios dentro de una misma institución.
SELECT id_coordinador, id_institucion, COUNT(*) AS voluntarios_a_cargo
FROM voluntario
WHERE id_coordinador IS NOT NULL
GROUP BY id_coordinador, id_institucion
HAVING COUNT(nro_voluntario) > 3
ORDER BY id_institucion DESC;
-- Se puede leer como "El coordinador 108, en la institucion 100 tiene 5 voluntarios a su cargo"

-- Consultas sobre más de una tabla (esquema películas)

-- Consultas para resolver mediante ensamble/s (NATURAL/INNER/OUTER JOIN). 

-- 11. Muestre los ids, nombres y apellidos de los empleados que no poseen jefe. Incluya también el nombre de la tarea que cada uno realiza, verificando que el sueldo máximo de la misma sea superior a 14800.
SELECT e.id_empleado, e.nombre, e.apellido, t.nombre_tarea, t.sueldo_maximo
FROM empleado e 
JOIN tarea t ON e.id_tarea = t.id_tarea
WHERE e.id_jefe IS NULL AND 
        t.sueldo_maximo > 14800;

-- 12. Determine si hay empleados que reciben un sueldo superior al de sus respectivos jefes.
SELECT e.nombre || ', ' || e.apellido AS datos_empleado,
       e.sueldo AS sueldo_empleado,
       j.nombre || ', ' || j.apellido AS datos_jefe,
       j.sueldo AS sueldo_jefe
FROM empleado e 
JOIN empleado j ON e.id_jefe = j.id_empleado
WHERE e.sueldo > j.sueldo;

-- 13. Liste el identificador, nombre y tipo de los distribuidores que hayan entregado películas en idioma Español luego del año 2010. Incluya en cada caso la cantidad de películas distintas entregadas
SELECT di.id_distribuidor, di.nombre, di.tipo, COUNT(DISTINCT p.titulo)
FROM distribuidor di 
JOIN entrega en ON (di.id_distribuidor = en.id_distribuidor)
JOIN renglon_entrega re ON (en.nro_entrega = re.nro_entrega)
JOIN pelicula p ON (re.codigo_pelicula = re.codigo_pelicula)
WHERE (p.idioma LIKE 'Español') AND (EXTRACT(year from en.fecha_entrega) > 2010)
GROUP BY di.id_distribuidor

-- 14. Para cada uno de los empleados registrados en la base, liste su apellido junto con el apellido de su jefe, en caso de tenerlo, sino incluya la expresión ‘(no posee)’. Ordene el resultado por el apellido del empleado.
SELECT e.apellido AS apellido_empleado, COALESCE(j.apellido, '(No posee)') AS apellido_jefe
FROM empleado e 
JOIN empleado j ON e.id_jefe = j.id_empleado
WHERE e.id_jefe IS NOT NULL
ORDER BY e.apellido;

-- 15. Liste el id y nombre de todos los distribuidores existentes junto con la cantidad de videos a los que han realizado entregas. Ordene el resultado por dicha cantidad en forma descendente.
SELECT di.id_distribuidor, di.nombre, COUNT(v.id_video) AS cantidad_videos
FROM distribuidor di
LEFT JOIN entrega en ON di.id_distribuidor = en.id_distribuidor
LEFT JOIN video v ON en.id_video = v.id_video 
GROUP BY di.id_distribuidor, di.nombre
ORDER BY cantidad_videos;

-- Consultas para resolver con subconsultas (IN, NOT IN, EXISTS, NOT EXISTS).

-- 16. Liste los datos de las películas que nunca han sido entregadas por un distribuidor nacional.
SELECT p.codigo_pelicula, p.titulo, p.idioma, p.genero
FROM pelicula p
WHERE p.codigo_pelicula NOT IN (
    SELECT re.codigo_pelicula
    FROM renglon_entrega re
    WHERE re.nro_entrega IN (
        SELECT en.nro_entrega
        FROM entrega en  
        WHERE en.id_distribuidor IN (
            SELECT di.id_distribuidor
            FROM distribuidor di 
            WHERE di.tipo = 'N'
        )
    )
);

-- 17. Indicar los departamentos (nombre e identificador completo) que tienen más de 3 empleados realizando tareas de sueldo mínimo inferior a 6000. Mostrar el resultado ordenado por el id de departamento.
SELECT d.id_departamento, d.id_distribuidor, d.nombre_departamento
FROM departamento d 
WHERE (d.id_departamento, d.id_distribuidor) IN (
    SELECT e.id_departamento, e.id_distribuidor
    FROM empleado e
    JOIN tarea t ON (e.id_tarea = t.id_tarea)
    WHERE t.sueldo_minimo < 6000
    GROUP BY e.id_departamento, e.id_distribuidor
    HAVING COUNT(e.id_empleado) > 3;
)
ORDER BY d.id_departamento;

-- 18. Liste los datos de los Departamentos en los que trabajan menos del 10 % de los empleados registrados.

-- Interpretación de resultados donde intervienen valores nulos

-- 25. Analice los resultados de los siguientes grupos de consultas:

-- a

-- a.1
SELECT avg(porcentaje), count(porcentaje), count(*)
FROM voluntario;
-- Cuenta el promedio de porcentaje, cuenta la cantidad de porcentajes y todas las filas. 

-- a.2
SELECT avg(porcentaje), count(porcentaje), count(*)
FROM voluntario WHERE porcentaje IS NOT NULL;
-- Hace lo mismo que en la consulta anterior pero no cuenta los valores nulos

-- a.3
SELECT avg(porcentaje), count(porcentaje), count(*)
FROM voluntario WHERE porcentaje IS NULL;
-- Toma promedio, cantidad de porcentajes y cantidad de filas de porcentajes nulos

-- b 

--b.1
SELECT * FROM voluntario
WHERE nro_voluntario NOT IN (
    SELECT id_director 
    FROM institucion
);
-- Se trae todos los voluntarios que no son directores de instituciones

-- b.2
SELECT * FROM voluntario
WHERE nro_voluntario NOT IN (
    SELECT id_director 
    FROM institucion
    WHERE id_director IS NOT NULL
);
-- Se trae todos aquellos voluntarios que no son directores, considerando nulos. No surte efecto que considere valores nulos ya que la subconsulta no devuelve los valores nulos

-- c

-- c.1 
SELECT i.id_institucion, count(*)
FROM institucion i 
LEFT JOIN voluntario v ON (i.id_institucion = v.id_institucion)
GROUP BY i.id_institucion;
-- Cuenta la cantidad de voluntarios que trabajaron para cada institucion

-- c.2
SELECT v.id_institucion, count(*)
FROM institucion i 
LEFT JOIN voluntario v ON (i.id_institucion = v.id_institucion)
GROUP BY v.id_institucion;
-- Devuelve los id de institucion asignadas a los voluntarios. 