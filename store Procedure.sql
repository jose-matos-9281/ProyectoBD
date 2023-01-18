use UniformesEscolares
go


-- Detalle Venta
DROP function IF EXISTS check_producto_venta
GO
create function check_producto_venta(@id_venta int, @id_detalle_catalogo int, @fecha_venta date)
returns int as 
begin
	declare @id_pedido int, @result int
	select @id_pedido = id_pedido from Venta where id_venta = @id_venta
	if dbo.check_pedido_abierto(@id_pedido, @fecha_venta) = 0
		return 0

	select @result = COUNT(*)
	from get_detalle_catalogo_Pedido(@id_pedido)
	where id_detalle_cat = @id_detalle_catalogo 

	if @result = 0 
		return 0;

	return 1
end
go

DROP PROCEDURE IF EXISTS SP_insert_detalle_venta
GO
create procedure SP_insert_detalle_venta 
(@id_venta int, @cantidad varchar(25), @id_detalle_catalogo int, @fecha_ingreso date = null )
as 
begin
	if @fecha_ingreso = null
		set @fecha_ingreso = getdate();

	if dbo.check_producto_venta(@id_venta, @id_detalle_catalogo, @fecha_ingreso) = 0
		throw 510000, 'El producto no puede ser ingresado',1
	
	declare @size varchar(10)
	declare @precio decimal(2)
	select @size=size, @precio=precio 
	from Detalle_catalogo dc
	inner join size s 
	on s.id_size = dc.id_size  
	where id_detalle_cat=@id_detalle_catalogo
	
	insert into Detalle_Venta(id_venta,id_detalle_catalogo,cantidad, size, precio,fecha_ingreso_Producto)
	values(@id_venta, @id_detalle_catalogo, @cantidad, @size, @precio, @fecha_ingreso)

end
go

DROP PROCEDURE IF EXISTS sp_update_detalle_venta
GO
create procedure sp_update_detalle_venta
(@id_detalle_venta int,@id_venta int, @precio decimal(2), @cantidad varchar(25), @id_detalle_catalogo int = null)
as 
begin
	declare @id_det_cat_ant int, @size varchar(10), @fecha_ingreso date
	select @id_det_cat_ant =  id_detalle_catalogo, @size = size, @fecha_ingreso=fecha_ingreso_Producto
	from Detalle_Venta where id_detalle_venta = @id_detalle_venta;

	if @id_detalle_catalogo is null
		set @id_detalle_catalogo = @id_det_cat_ant

	if @id_det_cat_ant <> @id_detalle_catalogo
		if dbo.check_producto_venta(@id_venta, @id_detalle_catalogo,@fecha_ingreso) = 0
			throw 510000, 'Cambio a Producto no valido', 1
		select @size = size , @fecha_ingreso = convert(date, GETDATE())
		from Detalle_catalogo dc 
		inner join size s 
		on s.id_size = dc.id_size  
		where id_detalle_cat = @id_detalle_catalogo

	update Detalle_Venta
	set id_venta=@id_venta,
		id_detalle_catalogo=@id_detalle_catalogo,
		precio=@precio,
		cantidad= @cantidad,
		size = @size,
		fecha_ingreso_Producto = @fecha_ingreso
	where id_detalle_Venta = @id_detalle_venta
end
go

DROP function IF EXISTS get_detalle_venta
GO
create function get_detalle_venta(@id_venta int )
returns table as return(

select * from Detalle_Venta  where id_Venta=@id_venta
)
go

-- Venta

DROP PROCEDURE IF EXISTS SP_insert_venta
GO
create procedure SP_insert_venta (@nombre varchar(25), @id_pedido int, @fecha_venta date = null )
as 
begin
	if @fecha_venta = null
		set @fecha_venta = getdate();

	if dbo.check_pedido_abierto(@id_pedido, @fecha_venta) = 0
		throw 510000, 'La fecha de venta no se encuentra en el rango de tiempo del pedido', 1

	insert into Venta(nombre_Estudiante,id_pedido,fecha_venta)
	values( @nombre, @id_pedido, @fecha_venta)
end
go

DROP function IF EXISTS check_update_pedido_venta
GO
create function check_update_pedido_venta(@id_venta int, @id_pedido_new int)
returns int
as begin
	declare @pedido int, @result int

	select @pedido= id_pedido from Venta where id_venta = @id_venta
	
	if @id_pedido_new = @pedido
		return 1

	select @result = COUNT(*)
	from dbo.get_detalle_venta(@id_venta) dv
	left join get_detalle_catalogo_Pedido(@id_pedido_new) cp
	on dv.id_detalle_catalogo = cp.id_detalle_cat
	where cp.id_detalle_cat is null
	
	if @result > 0
		return 0

	return 1
end
go

DROP PROCEDURE IF EXISTS SP_update_venta
GO
create procedure SP_update_venta
(@id_venta int, @nombre varchar(25) = null, @id_pedido int = null, @fecha_venta date = null)
as 
begin
	if @fecha_venta is null
		select @fecha_venta = fecha_venta from Venta where id_venta = @id_venta
	if @nombre is null
		select @nombre = nombre_Estudiante from Venta where id_venta = @id_venta
	if @id_pedido is null
		select @id_pedido = id_pedido from Venta where id_venta = @id_venta

	if dbo.check_pedido_abierto(@id_pedido, @fecha_venta) = 0 or dbo.check_update_pedido_venta(@id_venta,@id_pedido) = 0
		print('NO Se actualizo la venta');

	update venta
	set 
		nombre_Estudiante=@nombre,
		id_pedido=@id_pedido
	where id_venta=@id_venta
end
go

DROP function IF EXISTS get_venta
GO
create function get_venta(@id_venta int )
returns table as return (
select * from Venta  where id_venta=@id_venta
)
go

-- Escuela
DROP PROCEDURE IF EXISTS  SP_insert_Escuela
GO
create procedure SP_insert_Escuela (@nombre varchar(100), @director varchar(100) )
as 
begin
	insert into Escuela(nombre,director)
	values( @nombre, @director)
end
go

DROP PROCEDURE IF EXISTS SP_update_escuela
GO
create procedure SP_update_escuela(@id_escuela int, @nombre varchar(100), @director varchar(100))
as 
begin
	update Escuela
	set nombre=@nombre,
	director=@director
	where id_escuela=@id_escuela
end
go

DROP function IF EXISTS get_escuela
GO
create function get_escuela(@id_escuela int )
returns table as return(
select * from Escuela where id_escuela=@id_escuela
)
go

-- Producto
DROP PROCEDURE IF EXISTS SP_insert_Producto
GO
create procedure SP_insert_Producto (@nombre varchar(100), @descripcion text )
as 
begin
	insert into Producto(nombre,descripcion)
	values( @nombre, @descripcion)
end
go

DROP PROCEDURE IF EXISTS SP_update_producto
GO
create procedure SP_update_producto(@id_producto int, @nombre varchar(100), @descripcion text)
as 
begin
	update Producto
	set nombre=@nombre,
	descripcion=@descripcion
	where id_producto=@id_producto
end
go

DROP PROCEDURE IF EXISTS get_producto
GO
create procedure get_producto(@id_producto int )
as
begin
select * from Producto where id_producto=@id_producto
end
go


