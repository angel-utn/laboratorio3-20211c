/*
1) Hacer un trigger que al cargar un crédito verifique que el importe del mismo sumado a los importes de los créditos que actualmente solicitó esa persona no supere al triple de la declaración de ganancias. Sólo deben tenerse en cuenta en la sumatoria los créditos que no se encuentren cancelados. De no poder otorgar el crédito aclararlo con un mensaje.
*/
create trigger tr_nuevo_credito on Creditos
after insert
as
begin
    declare @creditos money, @ganancias money
    declare @dni varchar(10)
    select @dni = dni from inserted
    select @creditos = isnull(sum(importe), 0) from Creditos where dni = @dni and Cancelado = 0
    select @ganancias = DeclaracionGanancias from Personas where dni = @dni

    if (@creditos > @ganancias * 3) begin
        rollback transaction
        raiserror('No se pude otorgar el crédito', 16, 1)
    end
end
go
/*
2) Hacer un trigger que al eliminar un crédito realice la cancelación del mismo.
*/
create trigger tr_delete_credito on Creditos
instead of delete
as
begin
    update Creditos set Cancelado = 1 where ID = (select ID from deleted)
end
go
/*
3) Hacer un trigger que no permita otorgar créditos con un plazo de 20 o más años a personas cuya declaración de ganancias sea menor al promedio de declaración de ganancias.
*/
create trigger tr_nuevo_credito_2 on Creditos
after insert
as
begin
    declare @promedio money, @ganancias money
    declare @plazo smallint, @dni varchar(10)

    select @plazo = plazo, @dni = dni from inserted
    select @ganancias = DeclaracionGanancias from Personas where dni = @dni
    select @promedio = avg(DeclaracionGanancias) from Personas

    if @plazo >= 20 and @ganancias < @promedio begin
        rollback transaction
        raiserror('No se puede otorgar crédito', 16, 1)
    end
end
/*
4) Hacer un procedimiento almacenado que reciba dos fechas y liste todos los créditos otorgados entre esas fechas. Debe listar el apellido y nombre del solicitante, el nombre del banco, el tipo de banco, la fecha del crédito y el importe solicitado.
*/
go
create procedure sp_creditos(
    @Inicio date,
    @Fin date
)
as
begin
    select P.apellidos, P.nombres, B.nombre as Banco, B.tipo, C.Fecha, C.Importe
    from Personas P
    inner Join Creditos C on P.DNI = C.DNI
    inner join Bancos B on B.ID = C.IDBanco
    Where C.Fecha Between @Inicio and @Fin
end
