use UniformesEscolares
go

insert into dbo.Size (Size) values ('2'),('4'),('6'),('8'),('10'),('12'),('14'),('16'),('S'),('M'),('L'),('XL'),('XXL'),('XXL')
go

insert into dbo.Tanda (tanda) values ('Matutina'),('Vespertina'),('JEE')
go

insert into dbo.Seccion(seccion) values  ('A'),('B'),('C'),('D'),('E'),('F'),('G')
go

insert into dbo.Nivel_Estudiantil (descripcion) values ('Inicial'), ('Primaria'), ('Secundaria')
go

insert into dbo.grado (nombre, id_nivelEstudiantil) values ('PP',1),('Maternal',1),('Kinder',1)
go

declare @curso as table (curso varchar(10))  
insert into @curso (curso) values ('1RO'),('2DO'),('3RO'),('4TO'),('5TO'),('6TO')
insert into dbo.grado(nombre, id_nivelEstudiantil) 
select curso, n.id_nivelEstudiantil from @curso cross join dbo.nivel_estudiantil as n
where N.descripcion <> 'Inicial'
go

insert into dbo.grado_seccion 
select id_grado, id_seccion,id_tanda 
from dbo.grado
cross join dbo.seccion
cross join dbo.tanda
go

insert into dbo.producto (nombre) values ('camiseta de deporte'), ('pantalon de deporte')
go

insert into dbo.Escuela (nombre, direccion) values ('Juan Bosh','Ciudad juan bosh'), ('Cristobalina Batista','Herrera')
go

select * from dbo.Escuela
go

insert into dbo.Estado (descripcion) values ('Abierto'),('Cerrado'),('Reabierto'), ('Compra'),('Serigrafia'),('Empaque'),('Entregado')
go
