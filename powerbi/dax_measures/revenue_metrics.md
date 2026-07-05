# 💰 Revenue & Leakage Metrics

## Revenue Lost (Cancelled + Returned)
Revenue Lost (₹) =
CALCULATE (
    [Total Revenue],
    orders[order_status] IN { "Cancelled", "Returned" }
)

## Revenue Leakage Percentage
Revenue Leakage % =
DIVIDE (
    [Revenue Lost (₹)],
    [Total Revenue],
    0
)
