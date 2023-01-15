use UniformesEscolares
go

-- catalogo
create procedure SP_insert_catalogo (@nombre varchar(25))
as 
begin
	insert into catalogo (nombre) values(@nombre)
end
go

create procedure SP_update_catalogo(@id_catalogo int ,@nombre varchar(25))
as 
begin
	update catalogo 
	set nombre=@nombre 
	where id_catalogo=@id_catalogo
end
go

create procedure SP_get_catalogo(@id_catalogo int )
as begin
select * from catalogo  where id_catalogo=@id_catalogo
end 
go

-- catalogo_detalle
create procedure SP_insert_catalogo_detalle (
@id_catalogo int, @id_producto int, @id_size int, 
@precio decimal(2), @precio_combo decimal(2), @comision decimal(2)
) as 
begin
	insert into dbo.Detalle_catalogo (id_catalogo, id_producto, id_size, precio, precio_combo, comision)
	values(@id_catalogo, @id_producto, @id_size, @precio, @precio_combo, @comision)
end
go

create procedure SP_update_detalle_catalogo(
@id_detalle_catalogo int, @id_catalogo int, @id_producto int, @id_size int, 
@precio decimal(2), @precio_combo decimal(2), @comision decimal(2)
) as 
begin
	update Detalle_catalogo
	set id_catalogo= @id_catalogo,
		id_producto= @id_producto,
		id_size = @id_size,
		precio = @precio,
		precio_combo = @precio_combo,
		comision = @comision
	where id_detalle_cat = @id_detalle_catalogo
end
go

create function get_detalle_catalogo_Pedido(@id_pedido int )
returns table as return 	
(
select id_detalle_cat 
	from Pedido  p
	inner join catalogo c
	on c.id_catalogo = p.id_catalogo
	inner join Detalle_catalogo dt
	on dt.id_catalogo = c.id_catalogo
	where id_pedido = @id_pedido
)
go

-- check pedido_abierto
create function check_pedido_abierto (@id_pedido int, @fecha_venta date )
returns int as 
begin
	declare @fecha_inicio date, @fecha_fin date
	select @fecha_fin = fecha_fin, @fecha_inicio = fecha_inicio from Pedido where id_pedido = @id_pedido
	if @fecha_venta  between @fecha_inicio and  @fecha_fin
		return 1
	return 0
end
go


-- Detalle Venta

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

create procedure insert_detalle_venta 
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



create procedure update_detalle_venta
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

create function get_detalle_venta(@id_venta int )
returns table as return(

select * from Detalle_Venta  where id_Venta=@id_venta
)
go

-- Venta


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

create procedure SP_update_venta
(@id_venta int, @nombre varchar(25) = null, @id_pedido int = null, @fecha_venta date = null)
as 
begin
	if @fecha_venta is null
		select @fecha_venta = fecha_venta from Venta where id_venta = @id_venta
	if @id_pedido is null
		select @id_pedido = id_pedido from Venta where id_venta = @id_venta
	if @nombre is null
		select @nombre = nombre_Estudiante from Venta where id_venta = @id_venta
	else if dbo.check_pedido_abierto(@id_pedido, @fecha_venta) = 1 and dbo.check_update_pedido_venta(@id_venta,@id_pedido) = 1
		
		update venta
		set 
			nombre_Estudiante=@nombre,
			id_pedido=@id_pedido
		where id_venta=@id_venta
	else 
		print('NO Se actualizo la venta')
end
go

create procedure get_venta(@id_venta int )
as
begin
select * from Venta  where id_venta=@id_venta
end
go

-- Escuela
create procedure SP_insert_Escuela (@nombre varchar(100), @director varchar(100) )
as 
begin
	insert into Escuela(nombre,director)
	values( @nombre, @director)
end
go

create procedure SP_update_escuela(@id_escuela int, @nombre varchar(100), @director varchar(100))
as 
begin
	update Escuela
	set nombre=@nombre,
	director=@director
	where id_escuela=@id_escuela
end
go

create procedure get_escuela(@id_escuela int )
as
begin
select * from Escuela where id_escuela=@id_escuela
end
go

-- Producto
create procedure SP_insert_Producto (@nombre varchar(100), @descripcion text )
as 
begin
	insert into Producto(nombre,descripcion)
	values( @nombre, @descripcion)
end
go

create procedure SP_update_producto(@id_producto int, @nombre varchar(100), @descripcion text)
as 
begin
	update Producto
	set nombre=@nombre,
	descripcion=@descripcion
	where id_producto=@id_producto
end
go

create procedure get_producto(@id_producto int )
as
begin
select * from Producto where id_producto=@id_producto
end
go

-- Estado
create function get_id_estado(@nombre varchar(30))
returns int as 
begin 
	declare @id int;
	select @id=id_estado from Estado where nombre = @nombre 
	return @id
end 
go


-- Pedido
create procedure SP_insert_pedido (@id_escuela int, @fecha_inicio date, @fecha_fin date, @id_catalogo int )
as 
begin
	if @fecha_fin >= @fecha_inicio
		throw 510000, 'La fecha de inicio no puede ser menor o igual a la fecha fin', 1
	insert into Pedido(id_catalogo,id_escuela,fecha_inicio, fecha_fin)
	values(@id_catalogo, @id_escuela, @fecha_inicio, @fecha_fin)
end
go

create procedure SP_update_pedido(@id_pedido int, @id_escuela int, @fecha_inicio date, @fecha_fin date, @id_catalogo int)
as 
begin
	update Pedido
	set id_catalogo=@id_catalogo,
	id_escuela=@id_escuela,
	fecha_fin = @fecha_fin,
	fecha_inicio = @fecha_inicio
	where id_pedido=@id_pedido
end
go

create procedure get_pedido(@id_pedido int )
as
begin
select * from Pedido where id_pedido=@id_pedido
end
go



-- Estado_pedido
create function get_estado_actual_pedido(@id_pedido int)
returns int as 
begin 
	declare @result int
	select top 1 @result = id_estado 
		from Pedido_Estado
		where id_pedido = @id_pedido
		order by fecha_fin desc
	return @result
end
go

create procedure SP_insert_estado_Pedido 
(@id_pedido int, @id_estado int, @detalle_estado varchar(100) = null, @fecha_inicio date = null, @fecha_fin date = null )
as 
begin
	if @fecha_inicio = null
		set @fecha_inicio = getdate();

	insert into Pedido_Estado(id_pedido,id_estado,detalle_estado,fecha_inicio,fecha_fin)
	values( @id_pedido, @id_estado, @detalle_estado, @fecha_inicio, @fecha_fin)
end
go

create procedure sp_update_estado_pedido
(@id_pedido int, @id_estado int, @fecha_fin date = null, @detalle_estado varchar(100) = null)
as 
begin
	if @detalle_estado is null
		select @detalle_estado = detalle_estado 
		from Pedido_Estado 
		where id_estado = @id_estado
		and	id_pedido = @id_pedido
	update Pedido_Estado
	set 
	detalle_estado = @detalle_estado,
	fecha_fin = @fecha_fin
	where id_estado = @id_estado
	and	id_pedido = @id_pedido
end
go

create function get_estado_pedido(@id_estado int, @id_pedido int)
returns table as return
(
select * from Pedido_Estado
	where id_estado = @id_estado
	and	id_pedido = @id_pedido
)
go