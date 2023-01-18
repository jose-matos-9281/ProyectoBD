use UniformesEscolares
go

delete dbo.size
go
insert into dbo.Size (Size) values ('2'),('4'),('6'),('8'),('10'),('12'),('14'),('16'),('S'),('M'),('L'),('XL'),('XXL'),('XXL')
go

delete dbo.tanda
go
insert into dbo.Tanda (tanda) values ('Matutina'),('Vespertina'),('JEE')
go

delete dbo.seccion
go
insert into dbo.Seccion(seccion) values  ('A'),('B'),('C'),('D'),('E'),('F'),('G')
go

delete dbo.nivel
go
insert into dbo.Nivel (id_nivel, descripcion) values (1,'Inicial'), (2,'Primaria'), (3,'Secundaria')
go

delete dbo.grado
go
insert into dbo.grado (nombre, id_nivel) values ('PP',1),('Maternal',1),('Kinder',1)
go


declare @curso as table (curso varchar(10))  
insert into @curso (curso) values ('1RO'),('2DO'),('3RO'),('4TO'),('5TO'),('6TO')
insert into dbo.grado(nombre, id_nivel) 
select curso, n.id_nivel from @curso cross join dbo.nivel as n
where N.descripcion <> 'Inicial'
go


delete dbo.grado_seccion
go
insert into dbo.grado_seccion 
select id_grado, id_seccion,id_tanda 
from dbo.grado
cross join dbo.seccion
cross join dbo.tanda
go


delete dbo.Producto
go
insert into dbo.producto (nombre) values ('camiseta de deporte'), ('pantalon de deporte')
go


delete dbo.Escuela
go
insert into dbo.Escuela (nombre, director) values ('Juan Bosh','Ciudad juan bosh'), ('Cristobalina Batista','Herrera')
go


delete dbo.estado
go
insert into dbo.Estado (id_Estado, nombre, siguiente) values 
(1,'CREADO',2),
(2,'ABIERTO',3),
(3,'CERRADO',4),
(4,'COMPRADO',5),
(5,'SERIGRAFIADO',6),
(6,'EMPAQUADO',7),
(7,'ENTREGADO',0)
go

select * from Estado