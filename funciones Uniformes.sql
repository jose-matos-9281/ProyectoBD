use UniformesEscolares
go

drop function if exists get_id_GS
go
create function get_id_GS 
(@grado varchar(10), @tanda varchar(25), @seccion char(1), @nivel varchar(10))
returns int
as
begin 
	declare @results int
	select  @results= id_grado_seccion
		from dbo.Grado_Seccion gs
		inner join grado g
		on g.id_grado = gs.id_grado
		inner join Seccion s 
		on s.id_seccion = gs.id_seccion
		inner join Tanda t
		on t.id_tanda = gs.id_tanda
		inner join Nivel N
		on g.id_nivel = N.id_nivel
	where 
		tanda = @tanda
		and seccion = @seccion 
		and N.descripcion =  @nivel
		and g.nombre = @grado
	return @results
end 
go

create function get_grado(@id_nivel int)
returns table
as
return (select id_grado, nombre from dbo.Grado where id_nivel = @id_nivel)
go

create function get_nivel()
returns table
as
return (select id_nivel as id_nivel, descripcion as nivel from dbo.Nivel )
go

create function get_seccion()
returns table
as
return (select id_seccion, seccion from dbo.Seccion)
go

create function get_tanda()
returns table
as
return (select id_tanda, tanda from dbo.Tanda)
go


