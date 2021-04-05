use BluePrint

create table Modulos(
	ID int primary key identity(1,1) not null,
	Nombre varchar(50) not null,
	Descripcion varchar(512) null,
	CostoEstimado money not null check(CostoEstimado > 0),  
	TiempoEstimado smallint not null check(TiempoEstimado > 0),
	FechaInicio date null, 
	FechaEstimadaFin date null,
	FechaFin date null,
	IDProyecto varchar(5) not null foreign key references Proyectos(ID)
)

GO

ALTER TABLE Modulos add constraint CHK_FechaFin check (FechaFin >= FechaInicio)
ALTER TABLE Modulos add constraint CHK_FechaEstimadaFin check (FechaEstimadaFin >= FechaInicio)

GO


CREATE TABLE Paises(
	ID SMALLINT primary key identity(1,1) not null,
	Nombre varchar(50) not null
)

CREATE TABLE Ciudades(
	ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL, 
	Nombre VARCHAR(100) NOT NULL,
	IDPais SMALLINT not null foreign key references Paises(ID)
)

CREATE TABLE Colaboradores(
	ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL, 
	Nombre VARCHAR(100) NOT NULL,
	Apellido VARCHAR(100) NOT NULL, 
	FechaNacimiento DATE NOT NULL CHECK(FechaNacimiento < GETDATE()),
	Tipo CHAR(1) NOT NULL CHECK(Tipo = 'I' OR Tipo = 'E'),
	Domicilio VARCHAR(250) NULL,
	IDCiudad INT NULL foreign key references Ciudades(ID),
	EMail VARCHAR(250) NULL,
	Celular VARCHAR(50) NULL,
	CONSTRAINT CHK_EMailCelular CHECK(EMail IS NOT NULL OR Celular IS NOT NULL),
)

GO

ALTER TABLE Clientes
	ADD IDCiudad INT NULL foreign key references Ciudades(ID)

GO
/*

ALTER TABLE Clientes
	ALTER COLUMN IDCiudad INT NOT NULL

ALTER TABLE Clientes
	ALTER COLUMN EMail VARCHAR(150) NOT NULL

*/


