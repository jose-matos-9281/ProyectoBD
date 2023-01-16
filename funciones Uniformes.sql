use UniformesEscolares
go

create function get_id_GS (@id_grado int, @id_tanda int, @id_seccion int)
returns int
as
begin 
	declare @results int
	select  @results= id_gradoSeccion
		from dbo.Grado_Seccion
		where id_grado = @id_grado
		and id_seccion = @id_seccion
		and id_tanda = @id_tanda
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


