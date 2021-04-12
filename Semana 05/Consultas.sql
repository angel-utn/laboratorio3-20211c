Use BluePrint

-- 2)
-- Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Sólo de aquellos
-- clientes que posean ciudad y país.
select CL.razonsocial, CL.cuit, C.nombre as Ciudad, P.nombre as Pais
From Clientes as CL
Inner Join Ciudades as C ON C.ID = CL.IDCiudad
Inner Join Paises as P ON P.ID = C.IDPais

-- 3)
-- Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Listar también los datos de aquellos clientes que no tengan ciudad relacionada.
select CL.razonsocial, CL.cuit, C.nombre as Ciudad, P.nombre as Pais
From Clientes as CL
Left Join Ciudades as C ON C.ID = CL.IDCiudad
Left Join Paises as P ON P.ID = C.IDPais

-- 4)
-- Por cada cliente listar razón social, cuit y nombre de la ciudad y nombre del país. Listar también los datos de aquellas ciudades y países que no tengan clientes relacionados.
select CL.razonsocial, CL.cuit, C.nombre as Ciudad, P.nombre as Pais
From Clientes as CL
Right Join Ciudades as C ON C.ID = CL.IDCiudad
Right Join Paises as P ON P.ID = C.IDPais

-- 5)
-- Listar los nombres de las ciudades que no tengan clientes asociados. Listar también el nombre del país al que pertenece la ciudad.
select C.nombre as Ciudad, P.nombre as Pais
From Clientes as CL
Right Join Ciudades as C ON C.ID = CL.IDCiudad
Right Join Paises as P ON P.ID = C.IDPais
Where CL.ID is null

-- 6)
-- Listar para cada proyecto el nombre del proyecto, el costo, la razón social del cliente, el nombre del tipo de cliente y el nombre de la ciudad (si la tiene registrada) de aquellos clientes cuyo tipo de cliente sea 'Extranjero' o 'Unicornio'.

