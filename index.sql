use UniformesEscolares
go

DROP INDEX IF EXISTS IDXNC_catalogo_catalogo ON catalogo;
GO
CREATE NONCLUSTERED INDEX IDXNC_catalogo_catalogo
    ON catalogo(nombre);
GO

DROP INDEX IF EXISTS IDXNC_Detalle_catalogo_id_producto ON Detalle_catalogo;
GO
CREATE NONCLUSTERED INDEX IDXNC_Detalle_catalogo_id_producto
    ON Detalle_catalogo(id_producto);
GO

DROP INDEX IF EXISTS IDXNC_Detalle_catalogo_id_catalogo ON Detalle_catalogo;
GO
CREATE NONCLUSTERED INDEX IDXNC_Detalle_catalogo_id_catalogo
    ON Detalle_catalogo(id_catalogo);
GO

DROP INDEX IF EXISTS IDXNC_Detalle_Venta_id_detalle_catalogo ON Detalle_Venta;
GO
CREATE NONCLUSTERED INDEX IDXNC_Detalle_Venta_id_detalle_catalogo
    ON Detalle_Venta(id_detalle_catalogo);
GO

DROP INDEX IF EXISTS IDXNC_Detalle_Venta_id_venta ON Detalle_Venta;
GO
CREATE NONCLUSTERED INDEX IDXNC_Detalle_Venta_id_venta
    ON Detalle_Venta(id_venta);
GO

DROP INDEX IF EXISTS IDXNC_Escuela_nombre ON Escuela;
GO
CREATE NONCLUSTERED INDEX IDXNC_Escuela_nombre
    ON Escuela(nombre);
GO

DROP INDEX IF EXISTS IDXNC_Grado_id_nivel ON Grado;
GO
CREATE NONCLUSTERED INDEX IDXNC_Grado_id_nivel
    ON Grado(id_nivel);
GO

DROP INDEX IF EXISTS IDXNC_Grado_Seccion_id_tanda ON Grado_Seccion;
GO
CREATE NONCLUSTERED INDEX IDXNC_Grado_Seccion_id_tanda
    ON Grado_Seccion(id_tanda);
GO

DROP INDEX IF EXISTS IDXNC_Grado_Seccion_id_seccion ON Grado_Seccion;
GO
CREATE NONCLUSTERED INDEX IDXNC_Grado_Seccion_id_seccion
    ON Grado_Seccion(id_seccion);
GO

DROP INDEX IF EXISTS IDXNC_Grado_Seccion_id_grado ON Grado_Seccion;
GO
CREATE NONCLUSTERED INDEX IDXNC_Grado_Seccion_id_grado
    ON Grado_Seccion(id_grado);
GO

DROP INDEX IF EXISTS IDXNC_Pedido_id_catalogo ON Pedido;
GO
CREATE NONCLUSTERED INDEX IDXNC_Pedido_id_catalogo
    ON Pedido(id_catalogo);
GO

DROP INDEX IF EXISTS IDXNC_Pedido_id_escuela ON Pedido;
GO
CREATE NONCLUSTERED INDEX IDXNC_Pedido_id_escuela
    ON Pedido(id_escuela);
GO

DROP INDEX IF EXISTS IDXNC_Pedido_Estado_id_pedido ON Pedido_Estado;
GO
CREATE NONCLUSTERED INDEX IDXNC_Pedido_Estado_id_pedido
    ON Pedido_Estado(id_pedido);
GO

DROP INDEX IF EXISTS IDXNC_Pedido_Estado_id_estado ON Pedido_Estado;
GO
CREATE NONCLUSTERED INDEX IDXNC_Pedido_Estado_id_estado
    ON Pedido_Estado(id_estado);
GO

DROP INDEX IF EXISTS IDXNC_Venta_id_pedido ON Venta;
GO
CREATE NONCLUSTERED INDEX IDXNC_Venta_id_pedido
    ON Venta(id_pedido);
GO

DROP INDEX IF EXISTS IDXNC_Venta_nombre_estudiante ON Venta;
GO
CREATE NONCLUSTERED INDEX IDXNC_Venta_nombre_estudiante
    ON Venta(nombre_Estudiante);
GO