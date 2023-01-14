use UniformesEscolares
go

create procedure Crear_pedido 
( @id_escuela int, @fecha_apertura date,
@fecha_cierre date, @id_cat_prod int
)
as 
begin
	declare @valido int
	select @valido = COUNT(*) from Pedido 
	where id_escuela = @id_escuela	and id_cat_productos = @id_cat_prod
	and (
		(fecha_inicio < @fecha_cierre and fecha_inicio > @fecha_apertura)
		or(fecha_fin < @fecha_cierre and fecha_fin > @fecha_apertura)
		)
	if @valido= 0 
		insert into  dbo.Pedido (id_escuela,fecha_inicio, fecha_fin,id_cat_productos)
		values (@id_escuela,@fecha_apertura, @fecha_cierre,@id_cat_prod)
	else
		throw  51000, 'Ya existe un pedido abierto entre esas fecha', 1;
end
go

create procedure abrir_pedido
(@id_pedido int, @force int  = 0, @detalle_estado varchar(100)=null)
as 
begin 
	declare @valido  int
	select @valido = COUNT(*) from Pedido_Estado
		where id_pedido = @id_pedido

	if @valido > 0 
		throw  51000, 'El pedido ya fue abierto', 1;
	
	if @force > 0 
		update Pedido
		set fecha_inicio = CONVERT(date, getdate())
		where id_pedido = @id_pedido;

	select @valido = COUNT(*) from Pedido
		where id_pedido = @id_pedido
		and fecha_inicio < GETDATE()

	if @valido > 0 
	throw  51000, 'Aun no llega la fecha de apertura del pedido, 
	si desea abrirlo ahora use el paramentro @force = 1', 1;

	declare @estado int
	select @estado = id_estado from Estado where descripcion = 'Abierto'
	insert into Pedido_Estado (id_pedido,id_estado,detalle_estado)
	values (@id_pedido, @estado,@detalle_estado)
end
go

create function get_estado_pedido(@id_pedido int)
returns int
as
begin 
	declare @result int
	select top 1 @result = id_estado 
		from Pedido_Estado
		where id_pedido = @id_pedido
		order by fecha_fin desc
	return @result
end
go

create procedure cerrar_pedido (@id_pedido int,@force int = 0,  @detalle_estado varchar(100) = null)
as
begin
	declare @cerrado int;
	declare @abierto int;
	declare @estado int;
	declare @reabierto int;
	declare @fecha_cierre date;
	select @abierto = id_estado from Estado where descripcion = 'Abierto';
	select @reabierto = id_estado from Estado where descripcion = 'Reabierto';
	select @cerrado = id_estado from Estado where descripcion = 'Cerrado';
	set @estado = dbo.get_estado_pedido(@id_pedido)

	if @estado <> @abierto and @estado<>@reabierto 
		throw  51000, 'Solo puede cerrar un pedido Abierto o Reabierto', 1;
	
	if @force > 0
		update Pedido
		set fecha_fin = CONVERT(date, getdate())
		where id_pedido = @id_pedido;
		
	select @fecha_cierre = fecha_fin 
		from Pedido where id_pedido = @id_pedido;

	if @fecha_cierre < GETDATE()
		throw  51000, 'la fecha de cierre del pedido aun no ha llegado, si desea forzar el cierre use el parametro @force=1', 1;
	
	insert into Pedido_Estado (id_pedido,id_estado,detalle_estado)
	values (@id_pedido, @cerrado, @detalle_estado)
	
end
go

create procedure reabrir_pedido
(@id_pedido int, @fecha_fin date,  @detalle_estado varchar(100)=null)
as 
begin
	declare @cerrado int;
	declare @estado int;
	declare @reabierto int;
	select @reabierto = id_estado from Estado where descripcion = 'Reabierto';
	select @cerrado = id_estado from Estado where descripcion = 'Cerrado';
	set @estado = dbo.get_estado_pedido(@id_pedido)

	if @estado <> @cerrado 
		throw  51000, 'Solo puede Reabrir un pedido Cerrado', 1;
	
	insert into Pedido_Estado (id_pedido,id_estado,detalle_estado)
	values (@id_pedido, @reabierto, @detalle_estado)

end
go

