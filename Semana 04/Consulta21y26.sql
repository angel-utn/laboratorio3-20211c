/*
21 Listado de clientes cuya razón social contenga más de un espacio.
*/
Select RazonSocial from Clientes
Where RazonSocial Like '% % %'

/*
26 Listado de razón social, cuit y una columna llamada Contacto con el mail, si no posee mail, con el número de celular y si no posee número de celular, con el teléfono de lo contrario con un texto que diga "Incontactable".
*/
select RazonSocial, Cuit, 
case
--when email is null and celular is null and telefono is null then 'Incontactable'
when email is not null then email
when celular is not null then celular
when telefono is not null then telefono
else 'Incontactable'
end as 'Contacto'
from clientes

select RazonSocial, Cuit, isnull(email, isnull(celular, isnull(telefono, 'Incontatable'))) as Contacto from Clientes

select RazonSocial, Cuit, Coalesce(email, celular, telefono, 'Incontactable') as Contacto
From Clientes