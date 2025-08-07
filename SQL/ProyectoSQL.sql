--------------------------------------------------
-- BASE DE DATOS: VENTAS
-- Descripci�n: Script completo para base de datos de ventas
--              con tablas, datos, consultas anal�ticas,
--              funciones, procedimientos y vistas.
-- Nivel: Intermedio (DDL, DML, T-SQL avanzado)
--------------------------------------------------

--------------------------------------------------
-- SECCI�N 1: CREACI�N DE BASE DE DATOS Y ESQUEMAS
--------------------------------------------------
CREATE DATABASE Ventas;
USE Ventas;
GO

-- Tabla para regiones
CREATE TABLE Regiones (
    ciudad VARCHAR(100) PRIMARY KEY NOT NULL,  -- Relaci�n 1:1 con ciudad en Clientes
    regi�n VARCHAR(100) NOT NULL               -- Nombre de la regi�n
);
GO

-- Tabla de clientes con registro hist�rico
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),  -- Identificador autoincremental
    nombre VARCHAR(100) NOT NULL,              -- Nombre completo
    ciudad VARCHAR(100) NOT NULL,              -- Ciudad de residencia
    fecha_registro DATE NOT NULL               -- Fecha de registro (hist�rico)
	FOREIGN KEY(ciudad) REFERENCES Regiones(ciudad)
);

-- Cat�logo de productos
CREATE TABLE Productos (
    id_producto INT PRIMARY KEY IDENTITY(1,1),
    nombre_producto VARCHAR(100) NOT NULL,     -- Nombre descriptivo del producto
    categor�a VARCHAR(50) NOT NULL,            -- Categorizaci�n del producto
    precio_unitario DECIMAL(10,2) NOT NULL     -- Precio del producto
);

-- Registro detallado de transacciones
CREATE TABLE Ventas (
    id_venta INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,                   -- Relaci�n con cliente
    id_producto INT NOT NULL,                  -- Relaci�n con producto
    fecha_venta DATE NOT NULL,                 -- Fecha de la transacci�n
    cantidad INT NOT NULL,                     -- Unidades vendidas
    canal VARCHAR(50) NOT NULL,                -- Canal de venta 
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

--------------------------------------------------
-- SECCI�N 2: POBLADO DE DATOS DE EJEMPLO
--------------------------------------------------
-- Relaciones entre ciudades y regiones
INSERT INTO Regiones (ciudad, regi�n) VALUES
('Lima', 'Costa Central'),
('Arequipa', 'Sur'),
('Cusco', 'Sierra Sur'),
('Trujillo', 'Norte'),
('Piura', 'Norte'),
('Chiclayo', 'Norte');
GO

-- Clientes registrados (2022-2024)
INSERT INTO Clientes(nombre, ciudad, fecha_registro) VALUES 
('Luc�a Torres', 'Lima', '2022-05-15'),
('Carlos Ramos', 'Arequipa', '2022-07-22'),
('Ana G�mez', 'Cusco', '2022-09-12'),
('Pedro Quispe', 'Trujillo', '2023-01-08'),
('Mar�a Huam�n', 'Piura', '2023-03-19'),
('Diego S�nchez', 'Lima', '2023-06-05'),
('Laura Flores', 'Chiclayo', '2023-09-01'),
('Luis Paredes', 'Arequipa', '2023-10-11'),
('Jorge Salazar', 'Cusco', '2024-01-03'),
('Camila Rojas', 'Lima', '2024-03-21');

-- Cat�logo de productos b�sicos
INSERT INTO Productos(nombre_producto, categor�a, precio_unitario) VALUES 
('Papel Higi�nico', 'Limpieza', 11.50),
('Yogurt', 'L�cteos', 6.00),
('Leche', 'L�cteos', 4.50),
('Galletas', 'Snacks', 3.20),
('Jugo', 'Bebidas', 5.50),
('Detergente', 'Limpieza', 15.00),
('Agua Mineral', 'Bebidas', 2.00),
('Cereal', 'Desayuno', 9.00),
('Aceite', 'Cocina', 12.00);

-- Transacciones de enero a abril 2024
INSERT INTO Ventas(id_cliente, id_producto, fecha_venta, cantidad, canal) VALUES
(1, 2, '2024-01-10', 4, 'Tienda'),
(2, 3, '2024-01-15', 2, 'Online'),
(3, 5, '2024-02-01', 6, 'Mayorista'),
(4, 1, '2024-02-03', 3, 'Tienda'),
(5, 4, '2024-03-10', 5, 'Online'),
(6, 2, '2024-03-15', 2, 'Tienda'),
(7, 6, '2024-03-20', 1, 'Mayorista'),
(8, 8, '2024-04-01', 7, 'Online'),
(9, 9, '2024-04-05', 2, 'Tienda'),
(10, 1, '2024-04-10', 3, 'Online');

--------------------------------------------------
-- SECCI�N 3: CONSULTAS ANAL�TICAS (KPI's)
--------------------------------------------------

-- Total de ventas por producto (unidades e ingresos)
SELECT 
    p.nombre_producto AS Nombre_producto,
    SUM(v.cantidad) AS Total_unidades,
    SUM(v.cantidad * p.precio_unitario) AS Total_ventas
FROM [dbo].[Ventas] v
JOIN [dbo].[Productos] p ON v.id_producto = p.id_producto
GROUP BY Nombre_producto
ORDER BY Total_ventas DESC;

--Ventas mensuales (por a�o y mes)
SELECT 
    YEAR(v.fecha_venta) AS A�o,
    MONTH(v.fecha_venta) AS Mes,
    SUM(v.cantidad * p.precio_unitario) AS Total_ventas
FROM [dbo].[Ventas] v
JOIN [dbo].[Productos] p ON v.id_producto = p.id_producto
GROUP BY YEAR(v.fecha_venta), MONTH(v.fecha_venta)
ORDER BY A�o, Mes;

--Top 5 clientes con mayor compra
SELECT TOP 5 
    c.nombre AS Nombre,
    SUM(v.cantidad * p.precio_unitario) AS Total_compras
FROM [dbo].[Ventas] v
JOIN [dbo].[Clientes] c ON v.id_cliente = c.id_cliente
JOIN [dbo].[Productos] p ON v.id_producto = p.id_producto
GROUP BY c.nombre
ORDER BY Total_compras DESC;

-- Desempe�o por canal de venta
SELECT 
    canal,
    COUNT(*) AS Total_transacciones,
    SUM(cantidad * p.precio_unitario) AS Total_ventas
FROM [dbo].[Ventas] v
JOIN [dbo].[Productos] p ON v.id_producto = p.id_producto
GROUP BY canal
ORDER BY total_ventas DESC;

--Ventas totales por regi�n
SELECT r.regi�n AS Regi�n, 
	   SUM(v.cantidad * p.precio_unitario) AS Ventas_Totales
FROM [dbo].[Ventas] v 
INNER JOIN [dbo].[Clientes] c ON v.id_cliente = c.id_cliente
INNER JOIN [dbo].[Regiones] r ON c.ciudad = r.ciudad
INNER JOIN [dbo].[Productos] p ON v.id_producto = p.id_producto
GROUP BY r.regi�n
ORDER BY Ventas_Totales DESC

-- Productos l�deres por categor�a
SELECT p.categor�a AS Categor�a,
       p.nombre_producto AS Producto,
       SUM(v.cantidad) AS Unidades_Vendidas,
       SUM(v.cantidad * p.precio_unitario) AS Ingresos_Totales
FROM [dbo].[Ventas] v
INNER JOIN [dbo].[Productos] p ON v.id_producto = p.id_producto
GROUP BY p.categor�a, p.nombre_producto
ORDER BY Categor�a, Unidades_Vendidas DESC;

--Crecimiento mensual de clientes registrados
SELECT 
    YEAR(fecha_registro) AS A�o,
    MONTH(fecha_registro) AS Mes,
    COUNT(id_cliente) AS Nuevos_Clientes,
    SUM(COUNT(id_cliente)) OVER (ORDER BY YEAR(fecha_registro), MONTH(fecha_registro)) AS Clientes_Acumulados
FROM [dbo].[Clientes]
GROUP BY YEAR(fecha_registro), MONTH(fecha_registro)
ORDER BY A�o, Mes;

--------------------------------------------------
-- SECCI�N 4: FUNCIONES ESCALARES (C�LCULOS REUTILIZABLES)
--------------------------------------------------

-- 1. C�lculo de total por venta
CREATE FUNCTION CalcularTotalVenta (
	@cantidad INT,
	@precio_unitario DECIMAL(10,2) 
)
RETURNS DECIMAL(10,2)
AS
BEGIN
	RETURN @cantidad * @precio_unitario
END

--Uso de funci�n
SELECT 
    v.id_venta,
    dbo.CalcularTotalVenta(v.cantidad, p.precio_unitario) AS TotalVenta
FROM ventas v
JOIN productos p ON v.id_producto = p.id_producto;

-- 2. Clasificaci�n de ventas por monto
CREATE FUNCTION ObtenerCategoriaVenta(
	@total DECIMAL(10,2)
)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @categoria VARCHAR(10)

	IF @total >= 30
		SET @categoria = 'Alta'
	ELSE IF @total >= 20
		SET @categoria = 'Media'
	ELSE 
		SET @categoria = 'Baja'

	RETURN @categoria
END

--Uso de funci�n
SELECT 
    v.id_venta,
    p.precio_unitario * v.cantidad AS Total,
    dbo.ObtenerCategoriaVenta(p.precio_unitario * v.cantidad) AS Categoria
FROM ventas v
JOIN productos p ON v.id_producto = p.id_producto;


-- 3. Producto favorito por cliente
CREATE FUNCTION ObtenerTopProductoCliente (
    @id_cliente INT
)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @top_producto VARCHAR(100)

    SELECT TOP 1 @top_producto = p.nombre_producto
    FROM ventas v
    JOIN productos p ON v.id_producto = p.id_producto
    WHERE v.id_cliente = @id_cliente
    GROUP BY p.nombre_producto
    ORDER BY SUM(v.cantidad) DESC;

    RETURN @top_producto
END;

--Uso de funci�n
SELECT 
    id_cliente,
    dbo.ObtenerTopProductoCliente(id_cliente) AS ProductoFavorito
FROM clientes;


-- 4. Gasto por cliente en canal espec�fico
CREATE FUNCTION TotalCompradoCanal(
    @id_cliente INT,
    @canal VARCHAR(50)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2)

    SELECT @total = ISNULL(SUM(v.cantidad * p.precio_unitario), 0)
    FROM ventas v
    JOIN productos p ON v.id_producto = p.id_producto
    WHERE v.id_cliente = @id_cliente AND v.canal = @canal

    RETURN @total
END;

--Uso de funci�n
SELECT 
    id_cliente,
    dbo.TotalCompradoCanal(id_cliente, 'Online') AS TotalOnline
FROM clientes;


--------------------------------------------------
-- SECCI�N 5: FUNCIONES DE TABLA (CONSULTAS PARAMETRIZADAS)
--------------------------------------------------

-- 1. Historial de compras por cliente
CREATE FUNCTION VentasPorCliente (@id_cliente INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        v.id_venta,
        v.fecha_venta,
        p.nombre_producto,
        v.cantidad,
        p.precio_unitario,
        (v.cantidad * p.precio_unitario) AS TotalVenta
    FROM ventas v
    JOIN productos p ON v.id_producto = p.id_producto
    WHERE v.id_cliente = @id_cliente
);

--Uso de funci�n
SELECT * FROM VentasPorCliente(1);

-- 2. Ventas en rango de fechas
CREATE FUNCTION VentasPorRangoFechas (
    @fecha_inicio DATE,
    @fecha_fin DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        v.id_venta,
        v.fecha_venta,
        c.nombre AS cliente,
        p.nombre_producto,
        v.cantidad,
        p.precio_unitario,
        (v.cantidad * p.precio_unitario) AS total
    FROM ventas v
    JOIN clientes c ON v.id_cliente = c.id_cliente
    JOIN productos p ON v.id_producto = p.id_producto
    WHERE v.fecha_venta BETWEEN @fecha_inicio AND @fecha_fin
);

--Uso de funci�n
SELECT * FROM VentasPorRangoFechas('2025-01-01', '2025-07-22');

-- 3. Agregado de ventas por regi�n
CREATE FUNCTION VentasPorRegion ()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        r.regi�n,
        SUM(v.cantidad * p.precio_unitario) AS TotalVentas
    FROM ventas v
    JOIN productos p ON v.id_producto = p.id_producto
    JOIN clientes c ON v.id_cliente = c.id_cliente
    JOIN regiones r ON c.ciudad = r.ciudad
    GROUP BY r.regi�n
);

--Uso de funci�n
SELECT * FROM VentasPorRegion();

--------------------------------------------------
-- SECCI�N 6: PROCEDIMIENTOS ALMACENADOS (L�GICA COMPLEJA)
--------------------------------------------------

-- 1. Reporte regional
CREATE PROCEDURE sp_VentasPorRegion
AS
BEGIN
	SELECT 
	        r.regi�n,
        SUM(v.cantidad * p.precio_unitario) AS TotalVenta
    FROM ventas v
    JOIN productos p ON v.id_producto = p.id_producto
    JOIN clientes c ON v.id_cliente = c.id_cliente
    JOIN regiones r ON c.ciudad = r.ciudad
    GROUP BY r.regi�n
    ORDER BY TotalVenta DESC;
END;

--Uso de procedimiento
EXEC sp_VentasPorRegion;

-- 2. Insersi�n de ventas 
CREATE PROCEDURE sp_InsertarVenta
    @id_cliente INT,
    @id_producto INT,
    @fecha_venta DATE,
    @cantidad INT,
    @canal VARCHAR(50)
AS
BEGIN
    INSERT INTO Ventas (id_cliente, id_producto, fecha_venta, cantidad, canal)
    VALUES (@id_cliente, @id_producto, @fecha_venta, @cantidad, @canal);
END;

--Uso de procedimiento
EXEC sp_InsertarVenta 
    @id_cliente = 1,
    @id_producto = 2,
    @fecha_venta = '2025-07-22',
    @cantidad = 10,
    @canal = 'Online';

-- 3. An�lisis de productos l�deres
CREATE PROCEDURE sp_TopProductosVendidos
    @top INT
AS
BEGIN
    SELECT TOP (@top)
        p.nombre_producto,
        SUM(v.cantidad) AS TotalVendidos
    FROM ventas v
    JOIN productos p ON v.id_producto = p.id_producto
    GROUP BY p.nombre_producto
    ORDER BY TotalVendidos DESC;
END;

--Uso de procedimiento
EXEC sp_TopProductosVendidos @top = 5;

-- 4. Reporte ejecutivo mensual
CREATE PROCEDURE sp_ReporteVentasMensual
    @anio INT,
    @mes INT
AS
BEGIN
    SELECT 
        c.nombre AS cliente,
        v.canal,
        SUM(v.cantidad * p.precio_unitario) AS TotalMensual
    FROM ventas v
    JOIN clientes c ON v.id_cliente = c.id_cliente
    JOIN productos p ON v.id_producto = p.id_producto
    WHERE MONTH(v.fecha_venta) = @mes AND YEAR(v.fecha_venta) = @anio
    GROUP BY c.nombre, v.canal
    ORDER BY TotalMensual DESC;
END;

--Uso de procedimiento
EXEC sp_ReporteVentasMensual
    @anio = 2025,
    @mes = 7;

-- 5. Resumen regional avanzado
CREATE PROCEDURE sp_ResumenVentasPorRegion
AS
BEGIN
    SELECT 
        r.regi�n,
        COUNT(DISTINCT v.id_cliente) AS ClienteUnicos,
        SUM(v.cantidad * p.precio_unitario) AS TotalVentas
    FROM ventas v
    JOIN clientes c ON v.id_cliente = c.id_cliente
    JOIN productos p ON v.id_producto = p.id_producto
    JOIN regiones r ON c.ciudad = r.ciudad
    GROUP BY r.regi�n
    ORDER BY TotalVentas DESC;
END;

--Uso de procedimiento
EXEC sp_ResumenVentasPorRegion;

------------------------
-- SECCI�N 7: VISTAS 
------------------------

-- Vista resumen para reportes

CREATE VIEW vw_ResumenVentas AS
SELECT 
    v.id_venta,
    c.nombre AS cliente,
    p.nombre_producto,
    r.regi�n,
    v.cantidad,
    p.precio_unitario,
    v.fecha_venta,
    (v.cantidad * p.precio_unitario) AS Total
FROM ventas v
JOIN productos p ON v.id_producto = p.id_producto
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN regiones r ON c.ciudad = r.ciudad;

SELECT * FROM vw_ResumenVentas WHERE Total > 50;
