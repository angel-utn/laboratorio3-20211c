CREATE DATABASE BluePrint
GO

USE BluePrint
GO

CREATE TABLE TiposClientes(
	ID Smallint primary key identity (1,1) not null,
	Nombre varchar(40) not null
)

GO

CREATE TABLE Clientes(
	ID smallint primary key identity (1,1)not null,
	RazonSocial varchar(50) not null unique,
	CUIT varchar(13) not null unique,
	EMail varchar(100) null,
	Telefono varchar(15) null,
	Celular varchar(15) null,
	IDTipo smallint not null foreign key references TiposClientes(ID)
)
GO

CREATE TABLE Proyectos(
	ID smallint primary key identity (1,1) not null,
	IDCliente smallint not null foreign key references Clientes(ID),
	Nombre varchar(100) not null,
	Descripcion varchar (512) null,
	CostoEstimado money not null check ( CostoEstimado > 0),
	FechaInicio Date not null,
	FechaFin Date null,
	Estado bit not null default (1)
)
