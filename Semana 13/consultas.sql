/*
Hacer un trigger que al ingresar una colaboración obtenga el precio de la misma a partir del precio hora base del tipo de tarea. Tener en cuenta que si el colaborador es externo el costo debe ser un 20% más caro.
*/

--disable trigger tr_nueva_colaboracion on colaboraciones
--enable trigger tr_nueva_colaboracion on colaboraciones
--drop trigger tr_nueva_colaboracion

create trigger tr_nueva_colaboracion on colaboraciones
after insert
as
begin
    declare @IDTarea bigint
    declare @IDColaborador bigint
    select @IDTarea = IDTarea from inserted
    set @IDColaborador = (select IDColaborador from inserted)
    
    -- Obtener el precio hora tarea
    declare @Precio money
    select @Precio = TT.PrecioHoraBase from TiposTarea TT
    inner join Tareas T on TT.ID = T.IDTipo
    where T.ID = @IDTarea
    -- Verificar si es colaborador externo
    declare @TipoColab char
    select @TipoColab = Tipo from Colaboradores
    where ID = @IDColaborador
    
    if @TipoColab = 'E' begin
        set @Precio = @Precio * 1.2
    end
    -- Modificar el precio de la colaboración
    Update Colaboraciones set PrecioHora = @Precio
    where IDColaborador = @IDColaborador and IDTarea = @IDTarea
end


-- 10 Externo y 6 $ 2500 *1.2
insert into colaboraciones(IDTarea, IDColaborador, Tiempo, PrecioHora, Estado)
Values (7, 10, 50, 1, 1) -- $3000

-- 11 Interno y 6 $ 2500
insert into colaboraciones(IDTarea, IDColaborador, Tiempo, PrecioHora, Estado)
Values (6, 11, 50, 1, 1) -- $2500