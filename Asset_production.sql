-- Solving real life problems


CREATE TABLE Asset_Production (
    Asset_ID INT PRIMARY KEY,
    Asset_Name VARCHAR(100),
    Country VARCHAR(50),
    Asset_Type VARCHAR(50),
    Monthly_Revenue_M DECIMAL(10, 2),
    Monthly_Cost_M DECIMAL(10, 2),
    Status VARCHAR(20),
    Date DATE
);

TRUNCATE TABLE Asset_Production;

SET SESSION cte_max_recursion_depth = 5000;

INSERT INTO Asset_Production (Asset_ID, Asset_Name, Country, Asset_Type, Monthly_Revenue_M, Monthly_Cost_M, Status, Date)
WITH RECURSIVE seq AS (
    SELECT 501 AS id
    UNION ALL
    SELECT id + 1 FROM seq WHERE id < 2847
)
SELECT 
    id,
    CONCAT('Asset_', id) AS Asset_Name,
    ELT(FLOOR(RAND() * 8) + 1, 'USA', 'UK', 'Norway', 'Brazil', 'Nigeria', 'Angola', 'Saudi Arabia', 'Kazakhstan') AS Country,
    ELT(FLOOR(RAND() * 3) + 1, 'Offshore Rig', 'Onshore Well', 'Floating Platform') AS Asset_Type,
    ROUND(RAND() * 145 + 5, 2) AS Monthly_Revenue_M,
    CASE 
        WHEN RAND() < 0.15 THEN ROUND((RAND() * 50) + 100, 2) 
        ELSE ROUND(RAND() * 80 + 5, 2)
    END AS Monthly_Cost_M,
    ELT(FLOOR(RAND() * 3) + 1, 'Active', 'Maintenance', 'Decommissioned') AS Status,
    '2024-04-01' AS Date
FROM seq;

SELECT COUNT(*) FROM Asset_Production;

-- Question 1
-- "I've noticed some of our assets are losing money, and I suspect a few of our Offshore Rigs are the main culprits.
-- I need a clear report of every Offshore Rig that had a higher cost than revenue last month so we can decide
-- which ones to put into maintenance or decommission."

SELECT DISTINCT Asset_Type
FROM asset_production;

SELECT Asset_Name,
Country,
`Status`,
Net_loss
FROM asset_production
WHERE Asset_Type = 'Offshore Rig'
AND Monthly_Cost_M > Monthly_Revenue_M 
ORDER BY 4 DESC;

ALTER TABLE asset_Production 
ADD COLUMN Net_loss DECIMAL(10, 2);

SELECT *
FROM asset_production;

UPDATE asset_production
SET Net_loss = Monthly_Cost_M - Monthly_Revenue_M;

SELECT SUM(Net_loss)
FROM asset_production
WHERE Asset_Type = 'Offshore Rig'
AND Monthly_Cost_M > Monthly_Revenue_M ;

-- Question 2
-- "I want to see a summary table that shows the Total Revenue and Total Net Loss for each country, 
-- but only for our Active assets. Which country is struggling the most?"

SELECT Country,
SUM(Monthly_Revenue_M) AS Total_Revenue,
SUM(Net_loss) AS Total_Net_loss,
COUNT(`Status`) No_of_active_assets,
ROUND(AVG(Net_loss), 2),
MAX(Net_loss),
MIN(Net_loss)
FROM asset_production
WHERE `Status` = 'Active'
GROUP BY Country
ORDER BY Total_Net_Loss DESC;







