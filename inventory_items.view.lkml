view: inventory_items {
  sql_table_name: public.inventory_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension_group: created {
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
    sql: ${TABLE}.created_at ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: sold {
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
    sql: ${TABLE}.sold_at ;;
  }

  measure: count {
    type: count
    drill_fields: [id, products.id, products.item_name, order_items.count]
  }

  measure:  total_cost {
    type: sum
    sql:  ${cost} ;;
    value_format_name: "usd"
  }
  measure:  avg_cost {
    type:  average
    sql:  ${cost} ;;
    value_format_name: "usd"
  }

  measure: total_gross_margin {
    type: number
    sql:  ${order_items.total_revenue} - ${total_cost} ;;
    value_format_name: "usd"
  }

  measure:  average_gross_margin {
    type:  number
    sql: ${order_items.avg_sale_price} - ${avg_cost} ;;
    value_format_name: "usd"
  }

  measure:  gross_margin_percent {
    type: number
    sql: ${total_gross_margin}/${order_items.total_revenue} ;;
    value_format_name: "percent_2"
  }
}
