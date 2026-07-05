# ⏱️ Time Intelligence & Executive Metrics

*New file — adds the measures the original 4 DAX files were missing:
time intelligence, Average Order Value, Net Revenue, and Customer Lifetime Value.
These assume a `dim_date` table (marked as Date Table) is imported from the SQL
layer and related to `orders[order_date]`.*

## Net Revenue
Net Revenue =
CALCULATE (
    [Total Revenue],
    orders[order_status] = "Delivered"
)

## Average Order Value (AOV)
Average Order Value =
DIVIDE ( [Total Revenue], [Total Orders], 0 )

## Revenue - Previous Month
Revenue PM =
CALCULATE ( [Total Revenue], DATEADD ( dim_date[date], -1, MONTH ) )

## Revenue MoM %
Revenue MoM % =
DIVIDE ( [Total Revenue] - [Revenue PM], [Revenue PM], 0 )

## Revenue - Same Period Last Year
Revenue PY =
CALCULATE ( [Total Revenue], SAMEPERIODLASTYEAR ( dim_date[date] ) )

## Revenue YoY %
Revenue YoY % =
DIVIDE ( [Total Revenue] - [Revenue PY], [Revenue PY], 0 )

## Customer Lifetime Value (CLV)
CLV =
DIVIDE ( [Total Revenue], [Total Customers], 0 )

## Revenue Rank (for Pareto / top-N visuals)
Revenue Rank =
RANKX ( ALL ( products[product_name] ), [Total Revenue], , DESC )

## Cancellation Rate by Payment Mode (drill-through measure)
Cancellation Rate % =
DIVIDE (
    CALCULATE ( [Total Orders], orders[order_status] = "Cancelled" ),
    [Total Orders],
    0
)
