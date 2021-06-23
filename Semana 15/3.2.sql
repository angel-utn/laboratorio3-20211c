/*
    Hacer un trigger que al ingresar una colaboración obtenga el precio de la misma a partir del precio hora base del tipo de tarea. Tener en cuenta que si el colaborador es externo el costo debe ser un 20% más caro.
*/
-- Resuelto en consultas.sql de la Clase 13

/*
    Hacer un trigger que no permita que un colaborador registre más de 15 tareas en un mismo mes. De lo contrario generar un error con un mensaje aclaratorio.
*/
Create Trigger tr_nueva_colaboracion_2 on Colaboraciones
after insert
as
begin
        Declare @IDColab bigint
        Declare @IDTarea bigint
        Declare @Inicio date
        Declare @Fin date
        Declare @Cantidad smallint

        select @IDColab = IDColaborador, @IDTarea = IDTarea from inserted
        select @Inicio = FechaInicio, @Fin = FechaFin from Tareas where ID = @IDTarea

        -- Obtener datos necesarios de inserted
        Select @Cantidad = count(*) From Colaboraciones C
        inner join Tareas T on T.ID = C.IDTarea
        where C.IDColaborador = @IDColab and
        (
            @Inicio Between FechaInicio And FechaFin or 
            @Fin Between FechaInicio and FechaFin or
            @Inicio < FechaInicio And @Fin > FechaFin
        ) 
        
        if @Cantidad > 15 begin
            rollback transaction
            raiserror('Muchas tareas', 16, 1)
        end
end
/*
    Hacer un trigger que al ingresar una tarea cuyo tipo contenga el nombre 'Programación' se agreguen automáticamente dos tareas de tipo 'Testing unitario' y 'Testing de integración' de 4 horas cada una. La fecha de inicio y fin de las mismas debe ser NULL. Calcular el costo estimado de la tarea.
*/
Go
Create Trigger tr_nueva_tarea on Tareas
After Insert
as
Begin
    Declare @IDTipo int, @IDModulo int
    Declare @Tipo varchar(50)
    select @IDTipo = IDTipo, @IDModulo = IDModulo from inserted
    Select @Tipo = Nombre from TiposTarea where ID = @IDTipo
    
    if @Tipo like '%Programaci[óo]n%' begin
        insert into Tareas (IDModulo, IDTipo, FechaInicio, FechaFin, Estado)
        Values (@IDModulo, 10, null, null, 1)
        insert into Tareas (IDModulo, IDTipo, FechaInicio, FechaFin, Estado)
        Values (@IDModulo, 11, null, null, 1)
    end
End

/*
    Hacer un trigger que al borrar una tarea realice una baja lógica de la misma en lugar de una baja física.
*/
-- Realizado en la Clase 13

/*
    Hacer un trigger que al borrar un módulo realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas las tareas asociadas al módulo.
*/
-- Realizado en la Clase 13

/*
    Hacer un trigger que al borrar un proyecto realice una baja lógica del mismo en lugar de una baja física. Además, debe borrar todas los módulos asociados al proyecto.
*/
-- Similar a la realizada en la Clase 13

/*
    Hacer un trigger que si se agrega una tarea cuya fecha de fin es mayor a la fecha estimada de fin del módulo asociado a la tarea entonces se modifique la fecha estimada de fin en el módulo.
*/
go
Create Trigger tr_nueva_tarea_2 on Tareas
After Insert
as
begin
    Declare @FechaFinTarea date, @FechaFinModulo date
    Declare @IDModulo int
    
    select @FechaFinTarea = FechaFin, @IDModulo = IDModulo from inserted
    select @FechaFinModulo = FechaFin from Modulos where ID = @IDModulo

    if (@FechaFinTarea > @FechaFinModulo) begin
        update Modulos set FechaFin = @FechaFinTarea Where ID = @IDModulo
    end
end
go
/*
    Hacer un trigger que al borrar una tarea que previamente se ha dado de baja lógica realice la baja física de la misma.
*/
Create Trigger tr_baja_tarea_2 on Tareas
instead of delete
as
begin
    declare @IDTarea bigint
    declare @Estado bit

    select @IDTarea = ID, @Estado = Estado from deleted

    if @Estado = 1 begin
        Update Tareas set Estado = 0 where ID = @IDTarea
    end
    else begin
        Delete from Tareas where ID = @IDTarea
    end
end
/*
    Hacer un trigger que al ingresar una colaboración no permita que el colaborador/a superponga las fechas con las de otras colaboraciones que se les hayan asignado anteriormente. En caso contrario, registrar la colaboración sino generar un error con un mensaje aclaratorio.
*/
-- Ídem a tr_nueva_colaboracion_2 pero con la condición del IF > 1

/*
Hacer un trigger que al modificar el precio hora base de un tipo de tarea registre en una tabla llamada HistorialPreciosTiposTarea el ID, el precio antes de modificarse y la fecha de modificación.

NOTA: La tabla debe estar creada previamente. NO crearla dentro del trigger.
*/
Create Table HistorialPreciosTiposTarea(
    ID bigint not null primary key identity (1, 1),
    IDTipo bigint not null,
    PrecioActual money, -- Le agrego este campo para trabajar con ambas tablas (inserted y deleted)
    PrecioAnterior money,
    Fecha date
)
go
Create Trigger tr_cambio_tipotarea on TiposTarea
after update
as
begin
    declare @PrecioAnterior money, @PrecioActual money
    declare @IDTipo bigint

    select @PrecioAnterior = PrecioHoraBase from deleted
    select @PrecioActual = PrecioHoraBase, @IDTipo = ID from inserted

    if (@PrecioAnterior != @PrecioActual) begin
        insert into HistorialPreciosTiposTarea
        values (@IDTipo,@PrecioActual, @PrecioAnterior, getdate())
    end
end

select * from TiposTarea

update TiposTarea set Nombre = 'Análisis' where ID = 1
select * from HistorialPreciosTiposTarea