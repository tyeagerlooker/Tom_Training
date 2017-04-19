view: retention_cohort_analysis {
  derived_table: {
    sql: SELECT

                users.id as user_id
              , date_trunc ('month', users.created_at) as signup_month
              , month_list.purchase_month as purchase_month
              , COALESCE(data.monthly_purchases, 0) as monthly_purchases
              , COALESCE(data.total_purchase_amount, 0) as monthly_spend
              , row_number() over() AS key
            FROM
              users

            LEFT JOIN
      (
                SELECT
                  DISTINCT(date_trunc('month', orders.created_at)) as purchase_month
                FROM orders
              ) as month_list
            ON month_list.purchase_month >= date_trunc ('month', users.created_at)

            LEFT JOIN

              (
                SELECT
                      o.user_id
                    , date_trunc('month', o.created_at) as purchase_month
                    , COUNT(distinct o.id) AS monthly_purchases
                    , sum(oi.sale_price) AS total_purchase_amount

                FROM orders o
                JOIN order_items oi
                on o.id = oi.order_id
                GROUP BY 1,2
              ) as data
            ON data.purchase_month = month_list.purchase_month
            AND data.user_id = users.id
            ORDER BY 1, 3
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

  dimension_group: signup_month {
    type: time
    sql: ${TABLE}.signup_month ;;
  }

  dimension_group: purchase_month {
    type: time
    sql: ${TABLE}.purchase_month ;;
  }

  dimension: monthly_purchases {
    type: number
    sql: ${TABLE}.monthly_purchases ;;
  }

  dimension: monthly_spend {
    type: number
    sql: ${TABLE}.monthly_spend ;;
  }

  dimension: key {
    primary_key: yes
    type: number
    sql: ${TABLE}.key ;;
  }

  measure: total_users {
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [users.id, users.age, users.name, user_order_facts.lifetime_orders]
  }

  dimension: months_since_signup {
    type: number
    sql: datediff('month', ${TABLE}.signup_month, ${TABLE}.purchase_month) ;;
  }

  measure: total_active_users {
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [users.id, users.age, users.name, user_order_facts.lifetime_orders]

    filters: {
      field: monthly_purchases
      value: ">0"
    }
  }

  measure: percent_of_cohort_active {
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${total_active_users} / nullif(${total_users},0) ;;
    drill_fields: [user_id, monthly_purchases, total_amount_spent]
  }

  measure: total_amount_spent {
    type: sum
    value_format_name: usd
    sql: ${monthly_spend} ;;
    drill_fields: [detail*]
  }

  measure: spend_per_user {
    type: number
    value_format_name: usd
    sql: ${total_amount_spent} / nullif(${total_users},0) ;;
    drill_fields: [user_id, monthly_purchases, total_amount_spent]
  }

  measure: spend_per_active_user {
    type: number
    value_format_name: usd
    sql: ${total_amount_spent} / nullif(${total_active_users},0) ;;
    drill_fields: [user_id, total_amount_spent]
  }

  set: detail {
    fields: [
      user_id,
      signup_month_time,
      purchase_month_time,
      monthly_purchases,
      monthly_spend,
      key
    ]
  }
}
