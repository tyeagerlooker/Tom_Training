view: user_order_fact {
  derived_table: {
    persist_for: "12 hours"
    distribution: "id"
    sortkeys: ["id"]
    sql: SELECT c.id, a.lifetime_revenue, count(distinct b.id) as lifetime_order_count
FROM users c
LEFT JOIN
      (
      SELECT c.id as user_id, sum(sale_price) as lifetime_revenue
      FROM order_items a
      JOIN orders b
      ON a.order_id = b.id
      JOIN users c
      on b.user_id = c.id
      WHERE a.returned_at IS NULL and b.status <> 'cancelled'
      group by 1
      ) a
      on c.id = a.user_id
      JOIN orders b
      on c.id = b.user_id
      GROUP BY 1, 2
       ;;
  }

  measure: count {
    hidden:  yes
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.id ;;
    primary_key: yes
  }

  dimension: lifetime_revenue {
    type: number
    sql: ${TABLE}.lifetime_revenue ;;
    value_format_name: "usd"
  }

  dimension:  lifetime_revenue_tier {
    type: tier
    sql: ${lifetime_revenue} ;;
    tiers: [4.99, 19.99, 49.99, 99.99, 499.99, 999.99]
    style: interval
    value_format_name: "usd"
  }

  dimension: lifetime_order_count {
    type: number
    sql: ${TABLE}.lifetime_order_count ;;
  }

  dimension: order_count_tier {
    type: tier
    sql: ${lifetime_order_count} ;;
    tiers: [1, 2, 3, 5, 10]
    style:  integer
  }

  measure: avg_lifetime_revenue {
    type: average
    sql: ${lifetime_revenue} ;;
    value_format_name: "usd"
  }
  measure: avg_lifetime_order_count {
    type:  average
    sql: ${lifetime_order_count} ;;
  }

  set: detail {
    fields: [user_id, lifetime_revenue, avg_lifetime_revenue, lifetime_order_count]
  }
}
