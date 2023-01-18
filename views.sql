-- ventas

DROP VIEW IF EXISTS vPedidos;
GO
CREATE VIEW vPedidos AS
    SELECT PE.id_pedido, E.nombre as Estado, E.descripcion as DescripcionEstado,
       detalle_estado as Detalle, PE.fecha_inicio as FechaInicioEstado, PE.fecha_fin as FechaFinEstado,
       C.nombre Catalogo, Es.nombre as Escuela, Es.director as Director
    FROM Pedido_Estado PE
    INNER JOIN Pedido P on P.id_pedido = PE.id_pedido
    INNER JOIN Estado E on E.id_Estado = PE.id_estado
    INNER JOIN catalogo C on C.id_catalogo = P.id_catalogo
    INNER JOIN Escuela Es on Es.id_escuela = P.id_escuela;
GO

DROP VIEW IF EXISTS vCursos;
GO
CREATE VIEW vCursos AS
    SELECT GS.id_gradoSeccion, G.nombre as Grado, N.descripcion as Nivel, S.seccion as Seccion,
           T.tanda as Tanda
    FROM Grado_Seccion GS
    INNER JOIN Grado G on G.id_grado = GS.id_grado
    INNER JOIN Nivel N on N.id_nivel = G.id_nivel
    INNER JOIN Seccion S on S.id_seccion = GS.id_seccion
    INNER JOIN Tanda T on T.id_tanda = GS.id_tanda
        ;
GO

DROP VIEW IF EXISTS vVentas;
GO
CREATE VIEW vVentas AS
    SELECT V.id_venta as Venta, V.nombre_Estudiante as Estudiante, V.fecha_venta as FechaVenta,
           P.id_pedido as Pedido, E.nombre as Escuela, fecha_inicio as FechaInicioPedido,
		   fecha_fin as FechaFinPedido, c.nombre as Catalogo,
		   pr.nombre as producto, s.size, dv.precio
    FROM Venta V
    INNER JOIN Pedido P on P.id_pedido = V.id_pedido
    INNER JOIN Escuela E on E.id_escuela = P.id_escuela
	inner join catalogo c on c.id_catalogo= p.id_catalogo
	inner join Detalle_Venta dv on dv.id_venta = v.id_venta
    INNER JOIN Detalle_catalogo dc on dc.id_detalle_cat = dv.id_detalle_catalogo
	inner join Producto pr on pr.id_producto = dc.id_producto
	inner join size s on s.id_size = dc.id_size
        ;
GO
select * from vVentas

