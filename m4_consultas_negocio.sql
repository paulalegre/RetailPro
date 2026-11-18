-- Motor utilizado: MySQL 8.0 (en la consulta 2 se usa LIMIT 5 en lugar de TOP 5)
-- ==============================================================================
-- Pre-entrega Módulo 4: Consultas SQL de negocio 
-- Autor: Paula Alegre
-- Contexto: Extracción de métricas clave sobre la tabla ventas
-- de Ventas_Tech_DB para la reunión del equipo comercial.
-- ============================================================

USE Ventas_Tech_DB;

-- === CONSULTA 1: Resumen ejecutivo mensual ===

SELECT 
    MONTH(fecha_venta) AS mes_venta,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);

-- === CONSULTA 2: Ranking de productos (Top 5) ===

SELECT 
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC
LIMIT 5;

-- === CONSULTA 3: Clientes recurrentes ===

SELECT 
	id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_cliente 
HAVING COUNT(*) > 1;

-- === CONSULTA 4:  Productos por encima/por debajo del promedio ==

WITH TotalesPorProducto AS (
    SELECT
	    id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT 
	id_producto,
	total_facturado,
	CASE
		WHEN total_facturado > (SELECT AVG(total_facturado) FROM TotalesPorProducto) THEN 'Por encima'
		ELSE 'Por debajo'
	END AS rendimiento
FROM TotalesPorProducto;

-- Hallazgos
-- 1. El producto 1 genera $3,600 (casi el 56% de los ingresos del mes) con solo 3 unidades vendidas, y junto con el producto 3 son los únicos que quedan por encima del promedio por producto ($1,074).
-- 2. El producto 2 es el que más unidades vende (13 en total), pero termina quinto en facturación ($364) por tener un precio unitario bajo.
-- 3. Todos los clientes activos compraron 2 veces en el mes, aunque el gasto es muy dispar: los clientes 1 ($2,640) y 5 ($2,100) solos suman más del 73% de lo facturado.