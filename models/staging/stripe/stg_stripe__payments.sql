select 
    id as payment_id
    , orderid as order_id
    , paymentmethod
    , status
    , amount
    , created
    , _batched_at
from raw.stripe.payment
