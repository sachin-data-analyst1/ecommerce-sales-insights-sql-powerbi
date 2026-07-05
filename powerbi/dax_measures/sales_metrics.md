# 📊 Sales Metrics

## Total Orders
Total Orders =
DISTINCTCOUNT ( orders[order_id] )

## Total Quantity Sold
Total Quantity =
SUM ( order_item[quantity] )

## Total Revenue
Total Revenue =
SUM ( order_item[total_amount] )
