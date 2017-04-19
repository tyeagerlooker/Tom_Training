view: order_items {
  sql_table_name: public.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: is_returned {
    type:  yesno
    sql: ${returned_raw} IS NOT NULL ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: "usd"
  }

  measure: count {
    type: count
    drill_fields: [id, orders.id, inventory_items.id]
  }

  measure:  total_sale_price  {
    type:  sum
    sql:  ${sale_price} ;;
    value_format_name: "usd"
  }

  measure: avg_sale_price {
    type:  average
    sql:  ${sale_price} ;;
    value_format_name: "usd"
  }

  measure:  cum_total_sales {
    type: running_total
    sql:  ${total_sale_price} ;;
    value_format_name: "usd"
  }

  measure:  total_revenue {
    type:  sum
    sql:  ${sale_price} ;;
    filters: {
      field:  is_returned
      value: "no"
    }
    filters: {
      field:  orders.is_cancelled
      value: "no"
    }
    value_format_name: "usd"
  }

  measure: average_lifetime_revenue {
    type: average
    sql:  ${sale_price} ;;
    filters: {
      field:  is_returned
      value: "no"
    }
    filters: {
      field:  orders.is_cancelled
      value: "no"
    }
    value_format_name: "usd"
  }

  measure:  returned_order_count {
    type:  count
    filters: {
      field: is_returned
      value: "yes"
    }
  }

  measure:  item_return_rate {
    type: number
    sql: ${returned_order_count}/${count} ;;
    value_format_name: "decimal_4"
  }

  measure: number_of_customers_returning_items {
    type: count_distinct
    sql: ${users.id} ;;
    filters: {
      field:  is_returned
      value: "yes"
    }
  }

  measure: number_of_customers_returning_items_all {
    type: count_distinct
    sql: ${users.id} ;;
    filters: {
      field:  is_returned
      value: "yes, no"
    }
  }

  measure: number_of_customers_returning_items_no {
    type: count_distinct
    sql: ${users.id} ;;
    filters: {
      field:  is_returned
      value: "no"
    }
  }

  measure: percent_of_users_with_returns {
    type: number
    sql: ${number_of_customers_returning_items}/${users.count} ;;
    value_format_name: "percent_4"
  }

  measure:average_spend_per_user {
    type: number
    sql: ${total_sale_price}/${users.count} ;;
    value_format_name: "usd"
  }
}
