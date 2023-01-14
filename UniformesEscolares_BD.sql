use master
go
drop DATABASE if exists UniformesEscolares
go
CREATE DATABASE UniformesEscolares
GO
USE UniformesEscolares
GO
CREATE TABLE Escuela (
	id_escuela int NOT NULL IDENTITY(1,1),
	nombre varchar(100) NOT NULL,
	director varchar(100) NOT NULL,
	constraint PK_escuela PRIMARY KEY  (id_escuela)
)
GO
CREATE TABLE Tanda (
	id_tanda int NOT NULL IDENTITY(1,1),
	tanda varchar(25) NOT NULL,
	constraint PK_tanda PRIMARY KEY (id_tanda)
)
GO
CREATE TABLE Seccion (
	id_seccion int NOT NULL IDENTITY(1,1),
	seccion char NOT NULL,
	constraint PK_seccion PRIMARY KEY (id_seccion)
)
GO

CREATE TABLE Nivel (
	id_nivel int NOT NULL IDENTITY(1,1),
	descripcion varchar(10) NOT NULL,
	constraint PK_nivel PRIMARY KEY (id_nivel)
)
GO

CREATE TABLE Grado (
	id_grado int NOT NULL IDENTITY(1,1),
	nombre varchar(10) NOT NULL,
	id_nivel int NOT NULL,
	constraint PK_grado PRIMARY KEY (id_grado),
	constraint FK_nivel_grado FOREIGN KEY(id_nivel) REFERENCES Nivel(id_nivel)
)
GO

CREATE TABLE Grado_Seccion (
	id_gradoSeccion int NOT NULL IDENTITY(1,1),
	id_grado int NOT NULL, 
	id_seccion int NOT NULL,
	id_tanda int NOT NULL,
	constraint PK_grado_seccion PRIMARY KEY (id_gradoSeccion),
	constraint FK_grado_GS FOREIGN KEY (id_grado) REFERENCES Grado(id_grado),
	constraint FK_seccion_GS FOREIGN KEY (id_seccion) REFERENCES Seccion(id_seccion),
	constraint FK_tanda_GS FOREIGN KEY (id_tanda) REFERENCES Tanda(id_tanda)
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

CREATE TABLE Producto (
	id_producto int NOT NULL IDENTITY(1,1),
	nombre varchar(100) NOT NULL,
	descripcion text null,
	constraint PK_producto PRIMARY KEY (id_producto)
)
GO

CREATE TABLE Estado (
	id_Estado int NOT NULL IDENTITY(1,1),
	nombre varchar(30) not null,
	descripcion varchar(100) NULL,
	constraint PK_estado PRIMARY KEY (id_Estado)
)
GO

CREATE TABLE catalogo (
	id_catalogo int NOT NULL IDENTITY(1,1),
	nombre varchar(25) NOT NULL,
	fecha_creacion date NOT NULL default getdate(),
	constraint PK_cat_producto PRIMARY KEY (id_catalogo)
)
GO

CREATE TABLE Detalle_catalogo (
	id_detalle_cat int NOT NULL IDENTITY(1,1),
	id_catalogo int NOT NULL,
	id_producto int NOT NULL, 
	size varchar(10) NOT NULL,
	precio decimal(2) NOT NULL,
	precio_combo decimal(2) null,
	comision decimal(2) NOT NULL default 0,
	constraint PK_detalle_cat PRIMARY KEY (id_detalle_cat),
	constraint FK_cat_det FOREIGN KEY (id_catalogo) REFERENCES catalogo(id_catalogo),
	constraint FK_producto_det_cat FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
	)
GO

	CREATE TABLE Pedido (
	id_pedido int NOT NULL IDENTITY(1,1),
	id_escuela int NOT NULL,
	fecha_inicio date NOT NULL,
	fecha_fin date NOT NULL,
	id_catalogo int NOT NULL,
	constraint PK_pedido PRIMARY KEY (id_pedido),
	constraint FK_escuela_pedido FOREIGN KEY (id_escuela) REFERENCES Escuela(id_escuela),
	constraint FK_catalogo_pedido FOREIGN KEY (id_catalogo) REFERENCES catalogo(id_catalogo)
	)
GO

	CREATE TABLE Pedido_Estado (
	id_pedido_Estado int NOT NULL IDENTITY(1,1),
	id_pedido int NOT NULL,
	id_estado int NOT NULL,
	detalle_estado varchar(100) NOT NULL,
	fecha_inicio date NOT NULL default getdate(),
	fecha_fin date null,
	constraint PK_pedido_estado PRIMARY KEY (id_pedido_Estado),
	constraint FK_pedido_PE FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
	constraint PK_estado_PE FOREIGN KEY (id_estado) REFERENCES Estado(id_estado)
	)
GO

	CREATE TABLE Venta(
	id_venta int NOT NULL IDENTITY(1,1),
	nombre_Estudiante varchar(100) NOT NULL,
	id_pedido int NOT NULL,
	fecha_venta date NOT NULL default getdate(),
	constraint PK_venta PRIMARY KEY (id_venta),
	constraint FK_pedido_venta FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
	)
GO
CREATE TABLE Detalle_Venta(
	id_detalle_Venta int NOT NULL IDENTITY(1,1),
	id_venta int NOT NULL,
	id_detalle_catalogo int NOT NULL,
	cantidad int NOT NULL,
	precio decimal(2) NOT NULL,
	fecha_ingreso_Producto date NOT NULL default getdate(),
	constraint PK_detalle_venta PRIMARY KEY (id_detalle_Venta),
	constraint FK_venta_DV FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
	constraint FK_producto_DV FOREIGN KEY (id_detalle_catalogo) REFERENCES Detalle_catalogo(id_detalle_cat)
)
GO
