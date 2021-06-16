/*
Hacer un reporte que liste por cada tipo de tarea se liste el nombre, el precio de hora base y el promedio de valor hora real (obtenido de las colaboraciones).
*/
Create View VW_ReporteTiposTarea as
Select Aux.*, Aux.PromPrecioHora-Aux.PrecioHoraBase as Dif From (
select tt.Nombre, tt.PrecioHoraBase,
(
    select avg(c.PrecioHora) from Colaboraciones as c
    inner join tareas t on t.ID = c.IDTarea
    where t.IDTipo = tt.ID
) as PromPrecioHora
from TiposTarea tt
) as Aux
Go
/*
Modificar el reporte de (1) para que también liste una columna llamada Variación con las siguientes reglas:
Poca → Si la diferencia entre el promedio y el precio de hora base es menor a $500.
Mediana → Si la diferencia entre el promedio y el precio de hora base está entre $501 y $999.
Alta → Si la diferencia entre el promedio y el precio de hora base es $1000 o más.
*/
Alter View VW_ReporteTiposTarea as
select t2.*, case
when t2.Dif < 500 then 'Poca'
When t2.Dif < 999 then 'Mediana'
Else 'Alta'
end as Variacion
 from (
    select t1.*, Abs(t1.PrecioHoraBase - t1.PromPrecioHora) as Dif 
    from (
        select tt.Nombre, tt.PrecioHoraBase,
        (
            select avg(c.PrecioHora) from Colaboraciones as c
            inner join tareas t on t.ID = c.IDTarea
            where t.IDTipo = tt.ID
        ) as PromPrecioHora
        from TiposTarea tt
    ) as t1
) as t2
Go
/*
Crear un procedimiento almacenado que liste las colaboraciones de un colaborador cuyo ID se envía como parámetro.
*/
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
Go
Exec SP_ColaboracionesxColaborador 1
Go
/*
Hacer una vista que liste por cada colaborador el apellido y nombre, el nombre del tipo (Interno o Externo) y la cantidad de proyectos distintos en los que haya trabajado.
Opcional: Hacer una aplicación en C# (consola, escritorio o web) que consuma la vista y la muestre por pantalla.
*/
Create View Reporte_Colaboradores
as
Select 
    C1.Apellido, 
    C1.Nombre, 
    Case When C1.Tipo = 'I' Then 'Interno' Else 'Externo' End as Tipo, 
    count(C2.IDColaborador) as Cantidad
From Colaboradores as C1
Inner Join Colaboraciones as C2 ON C1.ID = C2.IDColaborador
Group By C1.ID, C1.Apellido, C1.Nombre, C1.Tipo
GO
Select * From Reporte_Colaboradores
Go
/*
Hacer un procedimiento almacenado que reciba dos fechas como parámetro y liste todos los datos de los proyectos que se encuentren entre esas fechas.
*/
Create Procedure SP_ProyectosEntreFechas(
    @Inicio date,
    @Fin date
)
as
begin
    Set dateformat 'DMY'
    Select * From Proyectos 
    Where 
    @Inicio Between FechaInicio And FechaFin or
    @Fin Between FechaInicio and FechaFin OR
    @Inicio < FechaInicio And @Fin > FechaFin
end
GO
set DateFormat 'DMY'
Exec SP_ProyectosEntreFechas '1/12/2020', '29/12/2021'
Go
/*
Hacer un procedimiento almacenado que reciba un ID de Cliente, un ID de Tipo de contacto y un valor y modifique los datos de contacto de dicho cliente. El ID de Tipo de contacto puede ser: 1 - Email, 2 - Teléfono y 3 - Celular.
*/
Create Procedure SP_ModificarContacto(
    @ID bigint,
    @Tipo tinyint,
    @Valor text
)
as
begin
    If @Tipo = 1 begin
        Update Clientes Set Email = @Valor Where ID = @ID
    end
    Else If @Tipo = 2 begin
        Update Clientes Set Telefono = @Valor Where ID = @ID
    end
    Else If @Tipo = 3 begin
        Update Clientes Set Celular = @Valor Where ID = @ID
    end
end
Go
Exec SP_ModificarContacto 1, 1, 'mailcambiado@mail.com'
go
Exec SP_ModificarContacto 1, 2, '1234'
go
Exec SP_ModificarContacto 1, 3, '5678'
Go
Select * From Clientes Where ID = 1
/*
Hacer un procedimiento almacenado que reciba un ID de Módulo y realice la baja lógica tanto del módulo como de todas sus tareas futuras. Utilizar una transacción para realizar el proceso de manera atómica.
*/
Go
Create Procedure SP_BajaModulo(
    @ID bigint
)
as
Begin
    begin try
    begin transaction
    -- Baja lógica del módulo
        update Modulos set Estado = 0 Where ID = @ID
        if @@ROWCOUNT <> 1 begin
            RAISERROR ('Error', 16, 1)
        end
    -- Baja lógica de tareas futuras del módulo
        Update Tareas set Estado = 0 where IDModulo = @ID And FechaInicio > getdate() or FechaInicio is null

        commit transaction
    end try
    begin catch
        rollback transaction
        RAISERROR('Error al dar de baja el módulo', 16 ,1)
    end catch
End
go
exec SP_BajaModulo 2