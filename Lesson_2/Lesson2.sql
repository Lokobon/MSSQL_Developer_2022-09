/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
GO
/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/


SELECT StockItemID, StockItemName FROM Warehouse.StockItems
WHERE  StockItemName LIKE '%urgent%' or StockItemName LIKE 'Animal%'
GO

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT 
S.SupplierID
, S.SupplierName
--, P.PurchaseOrderID
from [Purchasing].[Suppliers] S 
LEFT JOIN [Purchasing].[PurchaseOrders] P
ON S.SupplierID = P.SupplierID
WHERE PurchaseOrderID IS NULL
GO

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

-- Вариант 1, без постраничной выборки.
SELECT o.OrderID
, format(o.OrderDate, 'dd.MM.yyyy') as OrderDate
, CASE 
WHEN DATEPART(m, o.OrderDate) = 1 THEN 'January'
WHEN DATEPART(m, o.OrderDate) = 2 THEN 'February'
WHEN DATEPART(m, o.OrderDate) = 3 THEN 'March'
WHEN DATEPART(m, o.OrderDate) = 4 THEN 'April'
WHEN DATEPART(m, o.OrderDate) = 5 THEN 'May'
WHEN DATEPART(m, o.OrderDate) = 6 THEN 'June'
WHEN DATEPART(m, o.OrderDate) = 7 THEN 'July'
WHEN DATEPART(m, o.OrderDate) = 8 THEN 'August'
WHEN DATEPART(m, o.OrderDate) = 9 THEN 'September'
WHEN DATEPART(m, o.OrderDate) = 10 THEN 'October'
WHEN DATEPART(m, o.OrderDate) = 11 THEN 'November'
WHEN DATEPART(m, o.OrderDate) = 12 THEN 'December'
ELSE 'New Month in our calendar!'
END AS [OrderMonth]
, CASE 
WHEN DATEPART(m, o.OrderDate) BETWEEN '1' AND '3' THEN '1st quarter'
WHEN DATEPART(m, o.OrderDate) BETWEEN '4' AND '6' THEN '2nd quarter'
WHEN DATEPART(m, o.OrderDate) BETWEEN '7' AND '9' THEN '3rd quarter'
WHEN DATEPART(m, o.OrderDate) BETWEEN '10' AND '12' THEN '4th quarter'
ELSE 'Check calendar'
END AS [Quarter number]
, CASE 
WHEN DATEPART(m, o.OrderDate) BETWEEN '1' AND '4' THEN '1st third'
WHEN DATEPART(m, o.OrderDate) BETWEEN '5' AND '8' THEN '2nd third'
WHEN DATEPART(m, o.OrderDate) BETWEEN '9' AND '12' THEN '3rd third'
ELSE 'Check calendar'
END AS [Third number]
, C.CustomerName
FROM Sales.Orders O
JOIN Sales.OrderLines OL
ON O.OrderID = OL.OrderID
JOIN Sales.Customers C
ON O.CustomerID = C.CustomerID
WHERE (OL.UnitPrice > 100 OR OL.Quantity > 20) AND O.PickingCompletedWhen IS NOT NULL
ORDER BY [Quarter number] ASC, [Third number] ASC, OrderDate ASC
GO
--Вариант 2, с постраничной выборкой.
DECLARE @PAGESIZE tinyint = 100, --Размер страницы
		@PAGENUM tinyint = 12 --Номер страницы
SELECT o.OrderID
, format(o.OrderDate, 'dd.MM.yyyy') as OrderDate
, CASE 
WHEN DATEPART(m, o.OrderDate) = 1 THEN 'January'
WHEN DATEPART(m, o.OrderDate) = 2 THEN 'February'
WHEN DATEPART(m, o.OrderDate) = 3 THEN 'March'
WHEN DATEPART(m, o.OrderDate) = 4 THEN 'April'
WHEN DATEPART(m, o.OrderDate) = 5 THEN 'May'
WHEN DATEPART(m, o.OrderDate) = 6 THEN 'June'
WHEN DATEPART(m, o.OrderDate) = 7 THEN 'July'
WHEN DATEPART(m, o.OrderDate) = 8 THEN 'August'
WHEN DATEPART(m, o.OrderDate) = 9 THEN 'September'
WHEN DATEPART(m, o.OrderDate) = 10 THEN 'October'
WHEN DATEPART(m, o.OrderDate) = 11 THEN 'November'
WHEN DATEPART(m, o.OrderDate) = 12 THEN 'December'
ELSE 'New Month in our calendar!'
END AS [OrderMonth]
, CASE 
WHEN DATEPART(m, o.OrderDate) BETWEEN '1' AND '3' THEN '1st quarter'
WHEN DATEPART(m, o.OrderDate) BETWEEN '4' AND '6' THEN '2nd quarter'
WHEN DATEPART(m, o.OrderDate) BETWEEN '7' AND '9' THEN '3rd quarter'
WHEN DATEPART(m, o.OrderDate) BETWEEN '10' AND '12' THEN '4th quarter'
ELSE 'Check calendar'
END AS [Quarter number]
, CASE 
WHEN DATEPART(m, o.OrderDate) BETWEEN '1' AND '4' THEN '1st third'
WHEN DATEPART(m, o.OrderDate) BETWEEN '5' AND '8' THEN '2nd third'
WHEN DATEPART(m, o.OrderDate) BETWEEN '9' AND '12' THEN '3rd third'
ELSE 'Check calendar'
END AS [Third number]
, C.CustomerName
FROM Sales.Orders O
JOIN Sales.OrderLines OL
ON O.OrderID = OL.OrderID
JOIN Sales.Customers C
ON O.CustomerID = C.CustomerID
WHERE (OL.UnitPrice > 100 OR OL.Quantity > 20) AND O.PickingCompletedWhen IS NOT NULL
ORDER BY [Quarter number] ASC, [Third number] ASC, OrderDate ASC
OFFSET (@PAGENUM - 1) * @PAGESIZE ROWS FETCH NEXT @PAGESIZE ROWS ONLY;
GO
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT
	PurSuppl.SupplierName
,	ApplDelM.DeliveryMethodName
,	PurPurscO.ExpectedDeliveryDate
,	ApplPeop.SearchName
FROM 
Purchasing.Suppliers PurSuppl
JOIN Purchasing.PurchaseOrders PurPurscO
	ON PurSuppl.SupplierID = PurPurscO.SupplierID 
JOIN Application.DeliveryMethods ApplDelM
	ON PurPurscO.DeliveryMethodID = ApplDelM.DeliveryMethodID
JOIN Application.People ApplPeop
	ON PurPurscO.ContactPersonID = ApplPeop.PersonID
WHERE (PurPurscO.ExpectedDeliveryDate BETWEEN '2013-01-01' AND '2013-01-31')
	AND (ApplDelM.DeliveryMethodName IN ('Air Freight','Refrigerated Air Freight'))
GO
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP(10)
	SalOrd.OrderDate
,	SalCust.CustomerName
,	ApplPeop.FullName 
FROM 
	Sales.Orders SalOrd
JOIN Sales.Customers SalCust
	ON SalOrd.CustomerID = SalCust.CustomerID
JOIN Application.People ApplPeop
	ON SalOrd.SalespersonPersonID = ApplPeop.PersonID
ORDER BY OrderDate desc
GO

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT
	SalCust.CustomerID
,	SalCust.CustomerName
,	SalCust.PhoneNumber
,	WHStIt.StockItemName
FROM 
	Sales.Customers SalCust
JOIN Sales.Invoices	SalInv 
	ON SalInv.CustomerID = SalCust.CustomerID
JOIN Sales.InvoiceLines	SalInvLin
	ON SalInvLin.InvoiceID =  SalInv.InvoiceID
JOIN Warehouse.StockItems WHStIt
	ON WHStIt.StockItemID = SalInvLin.StockItemID
WHERE StockItemName = 'Chocolate frogs 250g'
GO
