# ⚙️ Operational Metrics

## Cancelled Orders
Cancelled Orders =
CALCULATE (
    DISTINCTCOUNT ( orders[order_id] ),
    orders[order_status] = "Cancelled"
)

## Cancelled Percentage
Cancelled % =
DIVIDE (
    [Cancelled Orders],
    [Total Orders],
    0
)

## Returned Orders
Returned Orders =
CALCULATE (
    DISTINCTCOUNT ( orders[order_id] ),
    orders[order_status] = "Returned"
)

## Returned Percentage
Returned % =
DIVIDE (
    [Returned Orders],
    [Total Orders],
    0
)
