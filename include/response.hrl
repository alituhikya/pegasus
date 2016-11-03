-record(query_details_response,
{ customer_ref,
	customer_name,
	'Area/BouquetCode',
	customer_type,
	status_code,
	status_description,
	outstanding_balance
	}
).

-record(post_transaction_response,
{
	peg_pay_id,
	status_description,
	status_code
}
).

-record(get_status_response,
{
	status_code,
	status_description,
	receipt
}
).