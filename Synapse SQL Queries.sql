-- Total Sales by Each State

    SELECT
        [State], SUM([Sale Amount]) as [Total Sales]
    FROM
        OPENROWSET(
            BULK '<acount-url>/project-data-dump/project-csv-data/yearly_sales_data_2019_cleaned.csv',
            FORMAT = 'CSV',
			PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE
        ) AS [result]
    GROUP BY [State]

-- Total Sales By Each Product

    SELECT
        [Product], SUM([Sale Amount]) AS [Total Sum]
    FROM
        OPENROWSET(
            BULK '<account-url>/project-data-dump/project-csv-data/yearly_sales_data_2019_cleaned.csv',
            FORMAT = 'CSV',
			PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE
        ) AS [result]
    GROUP BY [Product]
    ORDER BY [Total Sum] DESC

-- Total Quantity of each product ordered

    SELECT
        [Product], SUM([Quantity Ordered]) as [Total Quantity]
    FROM
        OPENROWSET(
            BULK '<account-url>/project-data-dump/project-csv-data/yearly_sales_data_2019_cleaned.csv',
            FORMAT = 'CSV',
			PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE
        ) AS [result]
    GROUP BY [Product]
    ORDER BY [Total Quantity] DESC

-- Which customer made more than 15 orders during the year

    SELECT
        [Purchase Address], COUNT([Purchase Address]) as [Number of purchases]
    FROM
        OPENROWSET(
            BULK '<account-url>/project-data-dump/project-csv-data/yearly_sales_data_2019_cleaned.csv',
            FORMAT = 'CSV',
			PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE
        ) AS [result]
    GROUP BY [Purchase Address]
    HAVING COUNT([Purchase Address]) > 15

-- Which day in each month had the highest sales

    WITH CTE AS (SELECT
        CONVERT(char(10), [Order Date], 126) as [Date], SUM([Sale Amount]) as [Total Sales],
        ROW_NUMBER() OVER(PARTITION BY MONTH(CONVERT(char(10), [Order Date], 126)) ORDER BY SUM([Sale Amount]) DESC) as row_num
    FROM
        OPENROWSET(
            BULK '<account-url>/project-data-dump/project-csv-data/yearly_sales_data_2019_cleaned.csv',
            FORMAT = 'CSV',
			PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE
        ) AS [result]
    GROUP BY CONVERT(char(10), [Order Date], 126))
    SELECT [Date], [Total Sales]
    FROM CTE
    WHERE row_num = 1

-- Which city had the highest product sales 

    WITH CTE AS (SELECT
        [Product], [City], SUM([Sale Amount]) OVER(PARTITION BY [City] ORDER BY SUM([Sale Amount]) DESC) AS [Total Sales],
        ROW_NUMBER() OVER(PARTITION BY [City] ORDER BY SUM([Sale Amount])) as row_num
    FROM
        OPENROWSET(
            BULK '<account-url>/project-data-dump/project-csv-data/yearly_sales_data_2019_cleaned.csv',
            FORMAT = 'CSV',
			PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE
        ) AS [result]
    GROUP BY [Product], [City], [Sale Amount])
    SELECT [Product], [City], [Total Sales]
    FROM CTE
    WHERE row_num = 1
    ORDER BY [Total Sales] DESC

-- The rolling sum of sales filtered by each month. This where clause in this query can be modified to display results for each month

        SELECT
            [Order ID], [Product], [Order Date], [Sale Amount], [Purchase Address], SUM([Sale Amount]) 
            OVER(PARTITION BY DAY([Order ID]) ORDER BY [Order Date]) as rolling_sum
        FROM
            OPENROWSET(
                BULK '<account-url>/project-data-dump/project-csv-data/yearly_sales_data_2019_cleaned.csv',
                FORMAT = 'CSV',
				PARSER_VERSION = '2.0',
                HEADER_ROW = TRUE
            ) AS [result]
        WHERE MONTH([Order Date]) = 01
        ORDER BY [Order Date]
