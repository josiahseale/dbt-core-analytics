with orders as (

select * from {{ ref('stg_jaffle_shop__orders') }}
order by customer_id

),


successful_payments as (
    select * 
    exclude (payment_status)
    from {{ ref('int_successful_payments') }}
),

final as (
    select 
        *
    from orders
    left join successful_payments using (order_id)
    where order_status not ilike 'return%'
)

select * from final

