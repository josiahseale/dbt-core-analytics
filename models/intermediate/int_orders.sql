with orders as (

select * from {{ ref('stg_jaffle_shop__orders') }}
order by customer_id

),


successful_payments as (
    select * 
    exclude (status)
    from {{ ref('int_successful_payments') }}
),

final as (
    select 
        *
    from orders
    left join successful_payments using (order_id)
    where status not ilike 'return%'
)

select * from final

