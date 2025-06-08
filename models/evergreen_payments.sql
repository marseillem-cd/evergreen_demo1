with customers as  (
   select * from {{ ref('stg_customers' )}}
),


payments as (
   select * from {{ ref('stg_payments') }}
),


customer_payments as (
   select
       LOAN_DISPLAY_ID as LOANPRODISPLAYID,
       APPLY_DATE,
       TO_VARCHAR(APPLY_DATE, 'yyyy-MM') as APPLY_MONTH,
       sum(AMOUNT) as amount,
       sum(PRINCIPAL) as PRINCIPAL,
       sum(INTEREST) as INTEREST,
       sum(NSF_FEES) as NSF_FEES,
       sum(BLOOM) as BLOOM,
       sum(BLOOM_TAXES) as BLOOM_TAXES
   from payments
   group by 1,2,3
),


final as (
   select
       customers.LOANPRODISPLAYID as loanprodisplayid,
       customers.OPPID as oppid,
       customers.STAGE as stage,
       APPLY_DATE as apply_date,
       customer_payments.APPLY_MONTH as apply_month,
       coalesce(customer_payments.amount, 0) as amount,
       coalesce(customer_payments.PRINCIPAL, 0) as principal,
       coalesce(customer_payments.INTEREST, 0) as interest,
       coalesce(customer_payments.NSF_FEES, 0) as nsf_fees,
       coalesce(customer_payments.BLOOM, 0) as bloom,
       coalesce(customer_payments.BLOOM_TAXES, 0) as bloomtax
   from customer_payments
   left join customers using (LOANPRODISPLAYID)
)


select * from final