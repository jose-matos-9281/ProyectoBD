select * from Producto
select * from size
use UniformesEscolares
go

exec SP_insert_catalogo @nombre = N'Solo Camisetas'
exec SP_insert_catalogo @nombre = N'Camisetas y Pantalones'
go

declare @id_catalogo int
set @id_catalogo = dbo.get_id_catalogo('Camisetas y Pantalones')
/*
exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  9,
	@precio = 350,
	@comision = 50.00,
	@precio_combo =300.00
*/
exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  10,
	@precio = 350,
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  3,
	@precio = 350,
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  4,
	@precio = 350,
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  5,
	@precio = 350,
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  6,
	@precio = 350,
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  7,
	@precio = N'350',
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  8,
	@precio = 350,
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  11,
	@precio = 350,
	@comision = 50,
	@precio_combo =300

exec SP_insert_catalogo_detalle
	@id_catalogo = @id_catalogo,
	@id_producto = 3,
	@id_size =  2,
	@precio = 350,
	@comision = 50,
	@precio_combo =300
go

exec SP_Crear_pedido 
	@id_escuela = 1,
	@fecha_apertura = N'2023/1/10',
	@fecha_cierre = N'2023/2/11',
	@id_catalogo = 2
go

exec SP_abrir_pedido
	@id_pedido = 1
go
declare @fecha date, @producto int;
set @fecha = convert(date,getdate())
exec SP_insert_venta 
	@nombre = N'ELizabeth Pena',
	@id_pedido = 1,
	@grado  = N'1RO',
	@seccion = N'A',
	@tanda = N'JEE',
	@nivel = N'Primaria',
	@fecha_venta = @fecha
 
set @producto= dbo.get_id_detalle_catalogo('camiseta de deporte', '8')

exec SP_insert_detalle_venta 
	@id_venta = 1,
	@cantidad = 1,
	@id_detalle_catalogo = @producto

set @producto= dbo.get_id_detalle_catalogo('camiseta de deporte', '10')

exec SP_insert_detalle_venta 
	@id_venta = 1,
	@cantidad = 1,
	@id_detalle_catalogo = @producto

declare @fecha date, @producto int;

set @fecha = convert(date,getdate())

exec SP_insert_venta 
	@nombre = N'Jose Rodriguez',
	@id_pedido = 1,
	@grado  = N'1RO',
	@seccion = N'B',
	@tanda = N'JEE',
	@nivel = N'Primaria',
	@fecha_venta = @fecha


set @producto= dbo.get_id_detalle_catalogo('camiseta de deporte', '12')

exec SP_insert_detalle_venta 
	@id_venta = 2,
	@cantidad = 1,
	@id_detalle_catalogo = @producto


select *  from dbo.get_detalle_catalogo_Pedido(1)