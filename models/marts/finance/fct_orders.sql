with fact_orders as (
select
    order_id
    , customer_id
    , sum(amount) as amount
from {{ ref('int_orders') }}
group by order_id, customer_id
),

test_fact_orders_sum as (
    select 
        customer_id
        , sum(amount) as amount
    from fact_orders
    group by customer_id
),

test_fact_orders_avg as (
    select 
        avg(amount)
    from test_fact_orders_sum
)

select * from fact_orders
