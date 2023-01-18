use UniformesEscolares 
go

-- catalogo
DROP PROCEDURE IF EXISTS SP_insert_catalogo
GO
create procedure SP_insert_catalogo (@nombre varchar(25))
as 
begin
	insert into catalogo (nombre) values(@nombre)
end
go

DROP PROCEDURE IF EXISTS SP_update_catalogo
GO
create procedure SP_update_catalogo(@id_catalogo int ,@nombre varchar(25))
as 
begin
	update catalogo 
	set nombre=@nombre 
	where id_catalogo=@id_catalogo
end
go

DROP function IF EXISTS  get_catalogo
GO
create function get_catalogo(@id_catalogo int )
returns table as return(
select * from catalogo  where id_catalogo=@id_catalogo
)
go

DROP function IF EXISTS  get_id_catalogo
GO
create function get_id_catalogo(@nombre varchar(25) )
returns int as begin 
declare @result int
select @result = id_catalogo from catalogo  where nombre=@nombre
return @result
end
go

-- catalogo_detalle
DROP PROCEDURE IF EXISTS SP_insert_catalogo_detalle
GO
create procedure SP_insert_catalogo_detalle (
@id_catalogo int, @id_producto int, @id_size int, 
@precio money, @comision decimal(5,2), @precio_combo money=null
) as 
begin
	insert into dbo.Detalle_catalogo (id_catalogo, id_producto, id_size, precio, precio_combo, comision)
	values(@id_catalogo, @id_producto, @id_size, @precio, @precio_combo, @comision)
end
go

DROP PROCEDURE IF EXISTS SP_update_detalle_catalogo
GO
create procedure SP_update_detalle_catalogo(
@id_detalle_catalogo int, @id_catalogo int = null, @id_producto int= null, @id_size int= null, 
@precio money= null, @precio_combo money= null, @comision money= null
) as 
begin
	if @id_catalogo is null select @id_catalogo = id_catalogo	from Detalle_catalogo where id_detalle_cat = @id_detalle_catalogo;
	if @id_producto is null select @id_producto = id_producto	from Detalle_catalogo where id_detalle_cat = @id_detalle_catalogo;
	if @id_size is null		select @id_size = id_size			from Detalle_catalogo where id_detalle_cat = @id_detalle_catalogo;
	if @precio is null		select @precio = precio				from Detalle_catalogo where id_detalle_cat = @id_detalle_catalogo;
	if @precio_combo is null select @precio_combo = precio_combo from Detalle_catalogo where id_detalle_cat = @id_detalle_catalogo;
	if @comision is null	select @comision = comision			from Detalle_catalogo where id_detalle_cat = @id_detalle_catalogo;

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

DROP function IF EXISTS  get_detalle_catalogo_Pedido
GO
create function get_detalle_catalogo_Pedido(@id_pedido int)
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

DROP function IF EXISTS  get_id_detalle_catalogo
GO
create function get_id_detalle_catalogo(
	@producto varchar(100),@size varchar(10))
returns int as begin 
declare @result int
select @result =id_detalle_cat 
	from Detalle_catalogo dt
	inner join Producto p
	on dt.id_producto = p.id_producto
	inner join size s
	on dt.id_size= s.id_size
	where s.size = @size and p.nombre =@producto
return 	@result 
end
go

