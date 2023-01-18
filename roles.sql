use UniformesEscolares
go

CREATE ROLE basico AUTHORIZATION db_owner;
GO

DENY SELECT,DELETE,UPDATE,INSERT ON SCHEMA :: dbo TO [basico];
GO

GRANT EXECUTE ON OBJECT:: SP_insert_catalogo TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_update_catalogo TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_get_catalogo TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_insert_catalogo_detalle TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_update_detalle_catalogo TO [basico]; GO
GRANT EXECUTE ON OBJECT:: insert_detalle_venta TO [basico]; GO
GRANT EXECUTE ON OBJECT:: update_detalle_venta TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_insert_venta TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_update_venta TO [basico]; GO
GRANT EXECUTE ON OBJECT:: get_venta TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_insert_Escuela TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_update_escuela TO [basico]; GO
GRANT EXECUTE ON OBJECT:: get_escuela TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_insert_Producto TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_update_producto TO [basico]; GO
GRANT EXECUTE ON OBJECT:: get_producto TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_insert_pedido TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_update_pedido TO [basico]; GO
GRANT EXECUTE ON OBJECT:: get_pedido TO [basico]; GO
GRANT EXECUTE ON OBJECT:: SP_insert_estado_Pedido TO [basico]; GO
GRANT EXECUTE ON OBJECT:: sp_update_estado_pedido TO [basico]; GO

CREATE LOGIN  nevadaJackson
    WITH PASSWORD = '^r<D!Cn9Wy{(}9m6';
CREATE USER usrNevadaJackson FOR LOGIN nevadaJackson;
ALTER ROLE [basico] ADD MEMBER usrNevadaJackson;
GO

CREATE LOGIN isabelaAgustina
    WITH PASSWORD = '+~Sz,)mX=s2@HN.D';
CREATE USER usrIsabelaAgustina FOR LOGIN isabelaAgustina;
ALTER ROLE [db_owner] ADD MEMBER usrIsabelaAgustina;
GO