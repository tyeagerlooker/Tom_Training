view: user_lifetime_revenue {
  derived_table: {
    sql: SELECT c.id as user_id, sum(sale_price) as lifetime_revenue
      FROM order_items a
      JOIN orders b
      ON a.order_id = b.id
      JOIN users c
      on b.user_id = c.id
      WHERE a.returned_at IS NULL and b.status <> 'cancelled'
      group by 1
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_revenue {
    type: number
    sql: ${TABLE}.lifetime_revenue ;;
  }

  set: detail {
    fields: [user_id, lifetime_revenue]
  }
}
