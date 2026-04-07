customer_metrics = orders.groupby('customer_id').agg({
    'order_id': 'count',
    'payment_value': 'sum'
}).reset_index()