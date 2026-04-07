# import pandas as pd

# orders = pd.read_csv('../data/raw/orders.csv')

# orders['order_purchase_timestamp'] = pd.to_datetime(
#     orders['order_purchase_timestamp']
# )

# orders = orders.dropna()

# orders.to_csv('../data/processed/cleaned_orders.csv', index=False)



import pandas as pd

df = pd.read_csv('../data/orders_dataset.csv')

# check basic structure
print(df.info())
print(df.isnull().sum())
print("Duplicate rows:", df.duplicated().sum())

# remove exact duplicate rows if any
df = df.drop_duplicates()

# convert date columns to datetime
date_cols = [
    'order_purchase_timestamp',
    'order_approved_at',
    'order_delivered_carrier_date',
    'order_delivered_customer_date',
    'order_estimated_delivery_date'
]

for col in date_cols:
    df[col] = pd.to_datetime(df[col], errors='coerce')

# standardize text columns
df['order_status'] = df['order_status'].str.strip().str.lower()

# optional: remove rows where essential IDs are missing
df = df.dropna(subset=['order_id', 'customer_id'])

# create useful derived column
df['delivery_delay_days'] = (
    df['order_delivered_customer_date'] - df['order_estimated_delivery_date']
).dt.days

# preview cleaned data
df.head()