view: users {
  sql_table_name: public.users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension : age_tier {
    type: tier
    tiers: [15, 26, 36, 51, 66]
    style: integer
    sql:  ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    convert_tz: no
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

  dimension:is_new_user {
    type:  yesno
    sql: ${TABLE}.created_at > GETDATE() - 90;;
  }

  dimension:  is_mtd {
    type:  yesno
#     convert_tz: no
    sql: (EXTRACT(DAY FROM ${created_raw}) < EXTRACT(DAY FROM GETDATE())
      OR
      (
        EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
        EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE())
      )
      OR
      (
        EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
        EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
        EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())
      )
    ) ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: state {
    type: string
    map_layer_name: "us_states_1"
    sql: ${TABLE}.state ;;
    drill_fields: [products.brand, products.category]
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
    drill_fields: [age_tier, gender, city, state, created_date]
  }

  dimension: zip {
    type: number
    sql: ${TABLE}.zip ;;
  }

  dimension: days_since_signup {
    type: number
    sql: DATEDIFF('day', ${created_date}, GETDATE()) ;;
  }

  dimension: signup_day_tier {
    type:  tier
    sql: ${days_since_signup} ;;
    tiers: [90,180,365,730]
    style: integer
  }

  dimension: months_since_signup {
    type: number
    sql: DATEDIFF('month', ${created_date}, GETDATE()) ;;
  }

  dimension: signup_month_tier {
    type: tier
    sql: ${months_since_signup} ;;
    tiers: [1,2,3,5,10,25]
    style: integer
  }

  measure: count {
    type: count
    drill_fields: [id, first_name, last_name, orders.count]
  }

#   measure: active_user_count {
#     type: count
#     drill_fields: [id, first_name, last_name, orders.count]
#     filters: {
#       field: user_order_date_rank.is_active_user
#       value: "yes"
#     }
#   }

  measure: average_days_since_signup {
    type: average
    sql: ${days_since_signup} ;;
  }

  measure: average_months_since_signup {
    type: average
    sql: ${months_since_signup} ;;
  }
#
#   measure: total_sales {
#     type: sum
#     sql: ${order_items.sale_price} ;;
#     sql_distinct_key: ${order_items.id} || ${id} ;;
#   }
}
