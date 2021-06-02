-- 1) Hacer un reporte que por cada tipo de tarea se liste el nombre, el precio de hora base y el promedio de valor hora real (obtenido de las colaboraciones). 
Alter View VW_ReporteTiposTarea as
Select Aux.*, Aux.PromPrecioHora-Aux.PrecioHoraBase as Dif From (
select tt.Nombre, tt.PrecioHoraBase,
(
    select avg(c.PrecioHora) from Colaboraciones as c
    inner join tareas t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID
) as PromPrecioHora
from TiposTarea tt
) as Aux



-- Modificar el reporte para que también liste una columna llamada Variación con las siguientes reglas:
--Poca → Si la diferencia entre el promedio y el precio de hora base es menor a $500.
--Mediana → Si la diferencia entre el promedio y el precio de hora base está entre $501 y $999.
--Alta → Si la diferencia entre el promedio y el precio de hora base es $1000 o más.

-- 2)
-- Crear un procedimiento almacenado que liste las colaboraciones
-- de un colaborador cuyo ID se envía como parámetro.
Create Procedure SP_ColaboracionesxColaborador(
    @IDColab bigint
)
as
begin
    Select IDTarea, 
    Format(Tiempo/60, '00') + ':' + Format(Tiempo%60, '00') as Tiempo,
    PrecioHora from Colaboraciones
     where IDColaborador = @IDColab And Estado = 1
end

exec SP_ColaboracionesxColaborador 2