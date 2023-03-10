use master
go
drop DATABASE if exists UniformesEscolares
go
CREATE DATABASE UniformesEscolares
GO
USE UniformesEscolares
GO

ALTER DATABASE UniformesEscolares
SET AUTO_CREATE_STATISTICS ON;

CREATE TABLE Escuela(
	id_escuela int NOT NULL IDENTITY(1,1),
	nombre varchar(100) NOT NULL,
	director varchar(100) NOT NULL,
	constraint PK_escuela PRIMARY KEY clustered (id_escuela)
)
GO
CREATE TABLE Tanda(
	id_tanda int NOT NULL IDENTITY(1,1),
	tanda varchar(25) NOT NULL,
	constraint PK_tanda PRIMARY KEY clustered (id_tanda)
)
GO
CREATE TABLE Seccion(
	id_seccion int NOT NULL IDENTITY(1,1),
	seccion char NOT NULL,
	constraint PK_seccion PRIMARY KEY clustered (id_seccion)
)
GO
CREATE TABLE Nivel (
	id_nivel int NOT NULL,
	descripcion varchar(10) NOT NULL,
	constraint PK_nivel PRIMARY KEY clustered (id_nivel)
)
GO

CREATE TABLE Grado (
	id_grado int NOT NULL IDENTITY(1,1),
	nombre varchar(10) NOT NULL,
	id_nivel int NOT NULL,
	constraint PK_grado PRIMARY KEY clustered (id_grado),
	constraint FK_nivel_grado FOREIGN KEY(id_nivel) REFERENCES Nivel(id_nivel)
)
GO

CREATE TABLE Grado_Seccion (
	id_grado_seccion int NOT NULL IDENTITY(1,1),
	id_grado int NOT NULL, 
	id_seccion int NOT NULL,
	id_tanda int NOT NULL,
	constraint PK_grado_seccion PRIMARY KEY clustered (id_grado_seccion),
	constraint FK_grado_GS FOREIGN KEY (id_grado) REFERENCES Grado(id_grado),
	constraint FK_seccion_GS FOREIGN KEY (id_seccion) REFERENCES Seccion(id_seccion),
	constraint FK_tanda_GS FOREIGN KEY (id_tanda) REFERENCES Tanda(id_tanda),
	constraint UN_GST unique (id_tanda,id_seccion, id_grado)
)
GO

/*
CREATE TABLE Estudiante (
	id_estudiante int NOT NULL IDENTITY(1,1),
	nombre varchar(100) NOT NULL,
	apellido varchar(100) NOT NULL,
	id_escuela int NOT NULL,
	id_gradoSeccion int NOT NULL,
	constraint PK_estudiante PRIMARY KEY (id_estudiante),
	constraint FK_estudiante_escuela FOREIGN KEY (id_escuela) REFERENCES Escuela(id_escuela),
	constraint FK_estudiante_GS FOREIGN KEY (id_gradoSeccion) REFERENCES Grado_Seccion(id_gradoSeccion)
)
GO
*/

CREATE TABLE size(
	id_size int NOT NULL IDENTITY(1,1),
	size varchar(10) NOT NULL,
	constraint PK_size PRIMARY KEY  (id_size)
)
GO
CREATE TABLE Producto (
	id_producto int NOT NULL IDENTITY(1,1),
	nombre varchar(100) NOT NULL,
	descripcion nvarchar(max) null,
	constraint PK_producto PRIMARY KEY clustered (id_producto)
)
GO

CREATE TABLE catalogo (
	id_catalogo int NOT NULL IDENTITY(1,1),
	nombre varchar(25) NOT NULL,
	fecha_creacion date NOT NULL default getdate(),
	constraint PK_cat_producto PRIMARY KEY clustered (id_catalogo)
)
GO

CREATE TABLE Detalle_catalogo (
	id_detalle_cat int NOT NULL IDENTITY(1,1),
	id_catalogo int NOT NULL,
	id_producto int NOT NULL, 
	id_size int NOT NULL,
	precio money NOT NULL,
	precio_combo money null,
	comision money NOT NULL default 0,
	constraint PK_detalle_cat PRIMARY KEY clustered (id_detalle_cat),
	constraint FK_cat_det FOREIGN KEY (id_catalogo) REFERENCES catalogo(id_catalogo),
	constraint FK_cat_det_size FOREIGN KEY (id_size) REFERENCES size(id_size),
	constraint FK_producto_det_cat FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
	)
GO

CREATE TABLE Estado (
	id_Estado int NOT NULL,
	nombre varchar(30) not null,
	descripcion varchar(100) NULL,
	siguiente int not null default 0,
	constraint PK_estado PRIMARY KEY clustered (id_Estado)
)
GO
	CREATE TABLE Pedido (
	id_pedido int NOT NULL IDENTITY(1,1),
	id_escuela int NOT NULL,
	fecha_inicio date NOT NULL,
	fecha_fin date NOT NULL,
	id_catalogo int NOT NULL,
	constraint PK_pedido PRIMARY KEY clustered (id_pedido),
	constraint FK_escuela_pedido FOREIGN KEY (id_escuela) REFERENCES Escuela(id_escuela),
	constraint FK_catalogo_pedido FOREIGN KEY (id_catalogo) REFERENCES catalogo(id_catalogo)
	)
GO

	CREATE TABLE Pedido_Estado (
	id_pedido int NOT NULL,
	id_estado int NOT NULL,
	detalle_estado varchar(100) NULL,
	fecha_inicio date NOT NULL default getdate(),
	fecha_fin date null,
	constraint PK_pedido_estado PRIMARY KEY (id_pedido, id_estado),
	constraint FK_pedido_PE FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
	constraint PK_estado_PE FOREIGN KEY (id_estado) REFERENCES Estado(id_estado)
	)
GO

	CREATE TABLE Venta(
	id_venta int NOT NULL IDENTITY(1,1),
	nombre_Estudiante varchar(100) NOT NULL,
	id_pedido int NOT NULL,
	fecha_venta date NOT NULL default getdate(),
	id_grado_seccion int not null,
	constraint PK_venta PRIMARY KEY clustered (id_venta),
	constraint FK_pedido_venta FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
	constraint FK_venta_grado FOREIGN KEY (id_grado_seccion) references Grado_seccion(id_grado_seccion)
	)
GO
CREATE TABLE Detalle_Venta(
	id_detalle_Venta int NOT NULL IDENTITY(1,1),
	id_venta int NOT NULL,
	id_detalle_catalogo int NOT NULL,
	cantidad int NOT NULL,
	size varchar(10) not null,
	precio money NOT NULL,
	fecha_ingreso_Producto date NOT NULL default getdate(),
	constraint PK_detalle_venta PRIMARY KEY clustered (id_detalle_Venta),
	constraint FK_venta_DV FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
	constraint FK_producto_DV FOREIGN KEY (id_detalle_catalogo) REFERENCES Detalle_catalogo(id_detalle_cat)
)
GO
