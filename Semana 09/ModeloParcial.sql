-- 1) Apellido y nombres de los pacientes cuya cantidad de turnos de 'Proctologia' sea mayor a 2.
select P.Apellido, P.Nombre from PACIENTES as P
inner join Turnos as T on P.IDPACIENTE = T.IDPACIENTE
inner join Medicos as M on M.IDMEDICO = T.IDMEDICO
inner join ESPECIALIDADES as E on E.IDESPECIALIDAD = M.IDESPECIALIDAD
Where E.NOMBRE = 'Proctologia'
Group By P.IDPACIENTE, P.APELLIDO, P.NOMBRE
Having count(*) > 2

-- 2) Los apellidos y nombres de los médicos (sin repetir) que hayan demorado en alguno de sus turnos menos de la duración promedio general de turnos.
select distinct M.apellido, M.Nombre from Medicos as M
inner join turnos as t on M.IDMEDICO = T.IDMEDICO
where T.Duracion < (select avg(duracion* 1.0) from turnos)

-- Vigliacco
SELECT ME.APELLIDO, ME.NOMBRE FROM MEDICOS AS ME
WHERE ME.IDMEDICO IN (
SELECT DISTINCT TU.IDMEDICO FROM TURNOS AS TU
WHERE TU.DURACION < (SELECT AVG(DURACION) FROM TURNOS)
)

-- Mena
select distinct CONCAT(M.NOMBRE,' ',M.APELLIDO) as Medicos
from MEDICOS as M
where 
(
	select AVG(T.DURACION) from TURNOS as T 
) > any (
	select distinct T.DURACION from TURNOS as T 
	where T.IDMEDICO = M.IDMEDICO
)
order by Medicos asc

-- 3) Por cada paciente, el apellido y nombre y la cantidad de turnos realizados en el primer semestre y la cantidad de turnos realizados en el segundo semestre. Indistintamente del año.

select P.apellido, P.Nombre,
(
    select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and month(FECHAHORA) <= 6
) as S1,
(
    select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and month(FECHAHORA) > 6
) as S2
From PACIENTES P

-- 4) Los pacientes que se hayan atendido más veces en el año 2000 que en el año 2001 y a su vez más veces en el año 2001 que en año 2002.
select T.Apellido, T.Nombre From (
    select P.apellido, P.Nombre,
    (
        select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and year(FECHAHORA) = 2000
    ) as C2000,
    (
        select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and year(FECHAHORA) = 2001
    ) as c2001,
    (
        select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and year(FECHAHORA) = 2002
    ) as c2002
    From PACIENTES P
) as T
Where T.C2000 > T.c2001 And T.c2001 > T.c2002


-- Alternativa
select P.apellido, P.Nombre
From PACIENTES P
Where 
    (
        select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and year(FECHAHORA) = 2000
    ) >
    (
        select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and year(FECHAHORA) = 2001
    )
    And
    (
        select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and year(FECHAHORA) = 2001
    ) >
    (
        select count(*) from Turnos where IDPACIENTE = P.IDPACIENTE and year(FECHAHORA) = 2002
    )