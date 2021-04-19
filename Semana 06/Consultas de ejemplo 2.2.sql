-- Listar nombre de proyectos que no hayan registrado tareas.
select PR.Nombre 
from Proyectos as PR
left join Modulos as M on PR.ID = M.IDProyecto
left join Tareas as T ON M.ID = T.IDModulo
where T.ID IS NULL


-- Ejemplo de Full Join
select CO.Apellido, CO.Nombre, CI.Nombre as Ciudad, P.Nombre as Pais
From Colaboradores as CO
full join Ciudades as CI ON CI.ID = CO.IDCiudad
full join Paises as P ON P.ID = CI.IDPais


-- Ejemplo con JOIN
select * from Clientes as C
inner join TiposCliente as TC on TC.ID = C.IDTipo
where C.Celular is not null or TC.Nombre = 'Extranjero'

-- Ejemplo resolviendo en el WHERE lo que realiza el JOIN. Nótese la necesidad de paréntesis en las condiciones del WHERE.
select * from Clientes as C, TiposCliente as TC
where C.IDTipo = TC.ID and (C.Celular is not null or TC.Nombre = 'Extranjero')