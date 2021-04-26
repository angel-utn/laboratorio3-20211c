-- 3 Listado de países que no tengan clientes relacionados.
select * from paises where id not in (
    select distinct p.id from paises p
    inner join ciudades c on p.id = c.IDPais
    inner join clientes cl on c.ID = cl.IDCiudad
)

--16 Por cada país listar el nombre, la cantidad de clientes y la cantidad de colaboradores

select p.Nombre,
(
    select count(*) from Clientes C
    inner join Ciudades C1 on C1.ID = C.IDCiudad
    where C1.IDPais = p.ID
) as Clientes,
(
    select count(*) from Colaboradores C
    inner join Ciudades C1 on C1.ID = C.IDCiudad
    where C1.IDPais = p.ID
) as Colaboradores
 from paises p


-- 17 Listar por cada país el nombre, la cantidad de clientes y la cantidad de colaboradores de aquellos países que no tengan clientes pero sí colaboradores.
Select *
from (
    select p.Nombre,
    (
        select count(*) from Clientes C
        inner join Ciudades C1 on C1.ID = C.IDCiudad
        where C1.IDPais = p.ID
    ) as Clientes,
    (
        select count(*) from Colaboradores C
        inner join Ciudades C1 on C1.ID = C.IDCiudad
        where C1.IDPais = p.ID
    ) as Colaboradores
    from paises p
) as MiTabla
Where MiTabla.Clientes = 0 and MiTabla.Colaboradores > 0
