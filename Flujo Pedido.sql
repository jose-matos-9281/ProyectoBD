use UniformesEscolares
go

-- Estado
DROP function IF EXISTS get_id_estado
GO
create function get_id_estado(@nombre varchar(30))
returns int as 
begin 
	declare @id int;
	select @id=id_estado from Estado where nombre = @nombre 
	return @id
end 
go


-- Estado_pedido
DROP function IF EXISTS secuencia_estado
GO
create function secuencia_estado(@id_estado int)
returns int as
begin
	declare @siguiente int
	select @siguiente = siguiente from Estado where id_Estado = @id_estado
	return @siguiente
end
go

DROP function IF EXISTS get_estado_actual_pedido
GO
create function get_estado_actual_pedido(@id_pedido int)
returns int as 
begin 
	declare @result int
	select top 1 @result = id_estado 
		from Pedido_Estado
		where id_pedido = 1  and fecha_fin is null
	if @result is null
		select @result = MAX(id_estado) from Estado
	return @result
end
go


-- check pedido_abierto
DROP function IF EXISTS check_pedido_abierto
GO
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

-- Pedido
DROP PROCEDURE IF EXISTS SP_insert_pedido
GO
create procedure SP_insert_pedido (@id_escuela int, @fecha_inicio date, @fecha_fin date, @id_catalogo int )
as 
begin
	if @fecha_fin <= @fecha_inicio
		throw 510000, 'La fecha de inicio no puede ser menor o igual a la fecha fin', 1
	insert into Pedido(id_catalogo,id_escuela,fecha_inicio, fecha_fin)
	values(@id_catalogo, @id_escuela, @fecha_inicio, @fecha_fin)
end
go

DROP PROCEDURE IF EXISTS SP_update_pedido
GO
create procedure SP_update_pedido
(@id_pedido int, @id_escuela int = null, @fecha_inicio date=null, @fecha_fin date= null, @id_catalogo int=null)
as 
begin
	if @id_escuela IS NULL select @id_escuela = id_escuela from Pedido where id_pedido = @id_pedido;
	if @id_catalogo IS NULL select @id_catalogo = id_catalogo from Pedido where id_pedido = @id_pedido;
	if @fecha_inicio IS NULL select @fecha_inicio = fecha_inicio from Pedido where id_pedido = @id_pedido;
	if @fecha_fin IS NULL select @fecha_fin = fecha_fin from Pedido where id_pedido = @id_pedido;

	update Pedido
	set id_catalogo=@id_catalogo,
	id_escuela=@id_escuela,
	fecha_fin = @fecha_fin,
	fecha_inicio = @fecha_inicio
	where id_pedido=@id_pedido
end
go

DROP function IF EXISTS get_pedido
GO
create function get_pedido(@id_pedido int )
returns table as return(

select * from Pedido where id_pedido=@id_pedido
)
go


DROP PROCEDURE IF EXISTS SP_insert_estado_Pedido
GO
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

DROP PROCEDURE IF EXISTS sp_update_estado_pedido
GO
create procedure sp_update_estado_pedido
(@id_pedido int, @id_estado int, @fecha_fin date = null, @detalle_estado varchar(100) = null)
as 
begin
	if @detalle_estado is null
		select @detalle_estado = detalle_estado 
		from Pedido_Estado 
		where id_estado = @id_estado
		and	id_pedido = @id_pedido
	if @fecha_fin is null
		select @fecha_fin = fecha_fin 
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

DROP function IF EXISTS get_estado_pedido
GO
create function get_estado_pedido(@id_estado int, @id_pedido int)
returns table as return
(
select * from Pedido_Estado
	where id_estado = @id_estado
	and	id_pedido = @id_pedido
)
go

DROP PROCEDURE IF EXISTS SP_cambiar_estado_pedido
GO
create procedure SP_cambiar_estado_pedido(@id_pedido int, @fecha date = null)
as begin
	declare @actual int, @proximo int, @nombre varchar(30), @fecha_inicio date
	set @actual = dbo.get_estado_actual_pedido(@id_pedido)
	select @nombre = nombre from Estado where id_Estado = @actual
	select @fecha_inicio=fecha_inicio from Pedido_Estado where id_Estado =@actual and id_pedido = @id_pedido

	if @fecha is null 
		set @fecha = GETDATE()
	
	if @fecha < @fecha_inicio
		throw 510000, 'La fecha final no puede ser menor a la fecha inicial', 1

	if @nombre = 'CREADO' and dbo.check_pedido_abierto(@id_pedido, @fecha) = 0
		throw 510000, 'No puede abrir el pedido', 1
	
	if @nombre = 'ABIERTO' 
		throw 510000, 'Este procedimiento no debe cerrar pedidos, por favor use SP_cerrar_pedido',1

	if @actual is not null
		begin
		set @proximo = dbo.secuencia_estado(@actual)
		exec sp_update_estado_pedido 
			@id_pedido = @id_pedido, 
			@id_estado = @actual,
			@fecha_fin = @fecha
		end
	else 
		select @proximo = dbo.get_id_estado('CREADO')

	if @proximo <> 0
		exec SP_insert_estado_Pedido 
			@id_pedido = @id_pedido,
			@id_estado = @proximo,
			@fecha_inicio = @fecha
		

end
go

DROP PROCEDURE IF EXISTS SP_Crear_pedido 
GO
create procedure SP_Crear_pedido 
( @id_escuela int, @fecha_apertura date,
@fecha_cierre date, @id_catalogo int
)
as 
begin
	declare @valido int, @id_pedido int
	select @valido = COUNT(*) from Pedido 
	where id_escuela = @id_escuela	and id_catalogo = @id_catalogo
	and (
		(fecha_inicio < @fecha_cierre and fecha_inicio > @fecha_apertura)
		or(fecha_fin < @fecha_cierre and fecha_fin > @fecha_apertura)
		)
	if @valido <> 0 
		throw  51000, 'Ya existe un pedido abierto entre esas fecha', 1;

	exec dbo.sp_insert_pedido 
		@id_escuela = @id_escuela, 
		@fecha_inicio = @fecha_apertura, 
		@fecha_fin = @fecha_cierre, 
		@id_catalogo = @id_catalogo
end
go

drop trigger if exists tg_aI_pedido
go
create trigger tg_aI_pedido on pedido after insert 
as begin 
	declare @id_pedido int
	select @id_pedido = id_pedido from inserted
	exec dbo.sp_cambiar_estado_pedido 
			@id_pedido = @id_pedido
end
go

DROP PROCEDURE IF EXISTS SP_abrir_pedido 
GO
create procedure SP_abrir_pedido
(@id_pedido int,  @detalle_estado varchar(100)=null)
as 
begin 
	declare @valido  int
	select @valido = COUNT(*) from Pedido_Estado pe
		inner join Estado e
		on e.id_Estado = pe.id_estado and e.nombre = 'ABIERTO'
		where id_pedido = @id_pedido


	if @valido > 0 
		throw  51000, 'El pedido ya fue abierto', 1;
	
	
	update Pedido
	set fecha_inicio = CONVERT(date, getdate())
	where id_pedido = @id_pedido;


	exec dbo.sp_cambiar_estado_pedido 
			@id_pedido = @id_pedido
end
go

drop procedure if exists sp_cerrar_pedido
go
create procedure sp_cerrar_pedido (@id_pedido int,@force int = 0,
@detalle_estado varchar(100) = null)
as
begin
	declare @cerrado int;
	declare @abierto int;
	declare @estado int;
	declare @fecha_cierre date;
	select @abierto = id_estado, @cerrado=siguiente
	from Estado where nombre = 'ABIERTO';
	set @estado = dbo.get_estado_actual_pedido(@id_pedido)

	if @estado <> @abierto 
		throw  51000, 'Solo puede cerrar un pedido Abierto', 1;
	
	if @force > 0
		update Pedido
		set fecha_fin = CONVERT(date, getdate())
		where id_pedido = @id_pedido;

		update Pedido_Estado
		set fecha_fin = CONVERT(date, getdate())
		where id_pedido = 1--@id_pedido 
		and id_estado = 2--@abierto;
		
	select @fecha_cierre = fecha_fin 
		from Pedido where id_pedido = @id_pedido;

	if @fecha_cierre > GETDATE()
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

