-- 6) Listado con ID, nombre y costo estimado de proyectos cuyo costo estimado sea menor al costo estimado de cualquier proyecto de clientes nacionales (clientes que sean de Argentina o no tengan asociado un país).
select * from Proyectos where CostoEstimado < (
    select Min(pr.CostoEstimado) from Proyectos as pr
    inner join Clientes as cl on cl.ID = pr.IDCliente
    left join Ciudades as c on c.ID = cl.IDCiudad
    left join Paises as p on p.ID = c.IDPais
    Where p.Nombre = 'Argentina' or cl.IDCiudad is null
)

select * from Proyectos where CostoEstimado <ALL (
    select pr.CostoEstimado from Proyectos as pr
    inner join Clientes as cl on cl.ID = pr.IDCliente
    left join Ciudades as c on c.ID = cl.IDCiudad
    left join Paises as p on p.ID = c.IDPais
    Where p.Nombre = 'Argentina' or cl.IDCiudad is null
)

-- 9) Listado de tareas indicando nombre del módulo, nombre del tipo de tarea, cantidad de colaboradores externos que la realizaron y cantidad de colaboradores internos que la realizaron.
select m.Nombre, tt.Nombre, col.Tipo, count(*) as cant from Modulos m
inner join Tareas as t on m.id = t.IDModulo
inner join TiposTarea as tt on tt.id = t.IDTipo
inner join Colaboraciones as c on t.id = c.IDTarea
inner join Colaboradores as col on col.id = c.IDColaborador
group by m.Nombre, tt.Nombre, col.Tipo
-- 
select m.Nombre as Modulo, tt.Nombre as Tipo,
(
    select count(distinct c1.ID) from Colaboradores c1
    inner join Colaboraciones c2 on c1.ID = c2.IDColaborador
    inner join Tareas t on t.id = c2.IDTarea
    where t.IDModulo = m.ID And t.IDTipo = tt.ID and c1.Tipo = 'I'
) as CantI,
(
    select count(distinct c1.ID) from Colaboradores c1
    inner join Colaboraciones c2 on c1.ID = c2.IDColaborador
    inner join Tareas t on t.id = c2.IDTarea
    where t.IDModulo = m.ID And t.IDTipo = tt.ID and c1.Tipo = 'E'
) as CantE
from Modulos m
inner join Tareas as t on m.id = t.IDModulo
inner join TiposTarea as tt on tt.id = t.IDTipo

-- Variante Aróstegui
SELECT 
(SELECT Mod.Nombre FROM Modulos Mod WHERE Mod.ID = Tar.IDModulo) Modulo,
(SELECT TT.Nombre FROM TiposTarea TT WHERE Tar.IDTipo = TT.ID) Tarea,
(SELECT COUNT(Col.ID) 
    FROM Colaboradores Col 
    JOIN Colaboraciones Colaciones ON Colaciones.IDColaborador = Col.ID
    JOIN Tareas Tar2 ON Colaciones.IDTarea = Tar2.ID
    WHERE Tar.ID = Tar2.ID AND Col.Tipo like 'I') Internos,
(SELECT COUNT(Col.ID) 
    FROM Colaboradores Col 
    JOIN Colaboraciones Colaciones ON Colaciones.IDColaborador = Col.ID
    JOIN Tareas Tar2 ON Colaciones.IDTarea = Tar2.ID
    WHERE Tar.ID = Tar2.ID AND Col.Tipo like 'E') Externo
FROM Tareas Tar

-- 11) Listado con nombre del tipo de tarea y promedio abonado en concepto de honorarios para colaboradores internos y promedio abonado en concepto de honorarios para colaboradores externos.
select tt.Nombre as Tipo,
(
    select isnull(avg(c.PrecioHora * c.Tiempo), 0) from Colaboraciones c
    inner join Colaboradores as col on col.ID = c.IDColaborador
    inner join Tareas as t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID AND col.Tipo = 'I'

) as HonorariosI,
(
    select isnull(avg(c.PrecioHora * c.Tiempo), 0) from Colaboraciones c
    inner join Colaboradores as col on col.ID = c.IDColaborador
    inner join Tareas as t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID AND col.Tipo = 'E'
) as HonorariosE
from TiposTarea tt

-- 11 Brian) Listado con nombre del tipo de tarea de aquellas cuyo  promedio abonado en concepto de honorarios para colaboradores internos sea mayor al promedio abonado en concepto de honorarios para colaboradores externos.

select tt.Nombre
 as Tipo,
 (
    select isnull(avg(c.PrecioHora * c.Tiempo), 0) from Colaboraciones c
    inner join Colaboradores as col on col.ID = c.IDColaborador
    inner join Tareas as t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID AND col.Tipo = 'I'

) as PromedioInterno
from TiposTarea tt
where 
(
    select isnull(avg(c.PrecioHora * c.Tiempo), 0) from Colaboraciones c
    inner join Colaboradores as col on col.ID = c.IDColaborador
    inner join Tareas as t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID AND col.Tipo = 'I'

) > 
(
    select isnull(avg(c.PrecioHora * c.Tiempo), 0) from Colaboraciones c
    inner join Colaboradores as col on col.ID = c.IDColaborador
    inner join Tareas as t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID AND col.Tipo = 'E'
)

-- Variante 2
select T1.Tipo, T1.HonorariosI from (
    select tt.Nombre as Tipo,
    (
        select isnull(avg(c.PrecioHora * c.Tiempo), 0) from Colaboraciones c
        inner join Colaboradores as col on col.ID = c.IDColaborador
        inner join Tareas as t on t.ID = c.IDTarea
        where t.IDTipo = tt.ID AND col.Tipo = 'I'
    ) as HonorariosI,
    (
        select isnull(avg(c.PrecioHora * c.Tiempo), 0) from Colaboraciones c
        inner join Colaboradores as col on col.ID = c.IDColaborador
        inner join Tareas as t on t.ID = c.IDTarea
        where t.IDTipo = tt.ID AND col.Tipo = 'E'
    ) as HonorariosE
    from TiposTarea tt
) as T1
Where t1.HonorariosI > t1.HonorariosE

-- 12 Listado con nombre del proyecto, razón social del cliente y saldo final del proyecto. El saldo final surge de la siguiente fórmula: 
-- Costo estimado - Σ(HCE) - Σ(HCI) * 0.1
-- Siendo HCE → Honorarios de colaboradores externos y HCI → Honorarios de colaboradores internos.

select pr.Nombre, cli.RazonSocial,
pr.CostoEstimado - 
(
    select isnull(sum(c.Tiempo * c.PrecioHora), 0) from Colaboraciones c
    inner join Colaboradores col on col.ID = c.IDColaborador
    inner join Tareas t on t.id = c.IDTarea
    inner join Modulos m on m.id = t.IDModulo
    where m.IDProyecto = pr.ID and col.Tipo = 'E'
) -
(
    select isnull(sum(c.Tiempo * c.PrecioHora), 0) from Colaboraciones c
    inner join Colaboradores col on col.ID = c.IDColaborador
    inner join Tareas t on t.id = c.IDTarea
    inner join Modulos m on m.id = t.IDModulo
    where m.IDProyecto = pr.ID and col.Tipo = 'I'
)*0.1
as SaldoFinal
From Proyectos as pr
inner join Clientes as cli on cli.ID = pr.IDCliente


-- Variantes en respuesta a Hugo
select RazonSocial, Coalesce(Celular, Telefono, Email, 'Jodete') as Contacto from Clientes

select RazonSocial, isnull(Celular, isnull(Telefono, isnull(Email, 'Jodete'))) as Contacto
From Clientes

select RazonSocial, 
Case
    When Celular is not null then Celular
    When Telefono is not null then Telefono
    When Email is not null then Email
    Else 'Jodete'
end Contacto
From Clientes
