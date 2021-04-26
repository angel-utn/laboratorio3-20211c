-- 2.3
---------

-- 20 Listar el promedio percibido en concepto de colaboraciones para colaboradores internos y el promedio percibido en concepto de colaboraciones para colaboradores externos.
select c2.Tipo, avg(Tiempo*PrecioHora) as 'Prom $' 
from Colaboraciones c
inner join Colaboradores c2 on c.IDColaborador = c2.ID
group by c2.Tipo

select 'Interno' as Tipo, avg(Tiempo*PrecioHora) as 'Prom $' 
from Colaboraciones c
inner join Colaboradores c2 on c.IDColaborador = c2.ID
where c2.Tipo = 'I'
UNION
select 'Externo' as Tipo, avg(Tiempo*PrecioHora) as 'Prom $' 
from Colaboraciones c
inner join Colaboradores c2 on c.IDColaborador = c2.ID
where c2.Tipo = 'E'

-- 21 Listar el nombre del proyecto y el total neto estimado. Este último valor surge del costo estimado menos los pagos que requiera hacer en concepto de colaboraciones.
select
	P.Nombre as Proyecto,
    P.CostoEstimado - isnull(SUM(CB.PrecioHora * CB.Tiempo), 0) as 'Total neto'
from Proyectos as P
	inner join Modulos as M on M.IDProyecto = P.ID
	inner join Tareas as T on T.IDModulo = M.ID
	inner join Colaboraciones as CB on CB.IDTarea = T.ID
group by P.Nombre, P.CostoEstimado

-- 22 Listar la cantidad de colaboradores distintos que hayan colaborado en alguna tarea que correspondan a proyectos de clientes de tipo 'Unicornio'.
select count(distinct c.IDColaborador) as Total from Colaboraciones c
inner join Tareas t on t.ID = c.IDTarea
inner join Modulos m on m.ID = t.IDModulo
inner join Proyectos p on p.ID = m.IDProyecto
inner join Clientes c1 on c1.ID = p.IDCliente
inner join TiposCliente tc on tc.ID = c1.IDTipo
where tc.Nombre like 'Unicornio'

-- 24 Por cada proyecto, la cantidad de módulos que se haya estimado mal la fecha de fin. Es decir, que se haya finalizado antes o después que la fecha estimada. Indicar el nombre del proyecto y la cantidad calculada.
select p.nombre, count(*) as Cant from Proyectos p
left join Modulos m on p.ID = m.IDProyecto
where m.FechaEstimadaFin != m.FechaFin
group by p.nombre
order by 2 desc
