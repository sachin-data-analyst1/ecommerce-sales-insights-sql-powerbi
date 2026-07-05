# 👥 Customer Metrics

## Total Customers
Total Customers =
DISTINCTCOUNT ( customers[customer_id] )

## Orders per Customer
Orders per Customer =
COUNT ( orders[order_id] )

## Repeat Customers
Repeat Customers =
CALCULATE (
    DISTINCTCOUNT ( orders[customer_id] ),
    FILTER (
        VALUES ( orders[customer_id] ),
        [Orders per Customer] > 1
    )
)

## New Customers
New Customers =
[Total Customers] - [Repeat Customers]
