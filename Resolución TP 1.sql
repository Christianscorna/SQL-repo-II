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