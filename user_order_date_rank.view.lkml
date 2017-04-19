view: user_order_date_rank {
  derived_table: {
    sql: SELECT a.user_id
      , a.order_id
      , a.max_order_date
      , a.max_rank
      , a.min_order_date
      , a.min_rank
      , a.created_at
      , a.rank
      , CASE WHEN LEAD(rank, 1) OVER(PARTITION BY user_id ORDER BY rank) IS NULL
        THEN 'no'
        ELSE 'yes'
        END  as "has_subsequent_order"
      , DATEDIFF('day', created_at, LEAD(created_at, 1) OVER(PARTITION BY user_id ORDER BY created_at)) as "days_between_order"
      , b.min_days_between_order
from
(
  SELECT a.user_id
        , a.max_order_date
        , a.max_rank
        , a.min_order_date
        , a.min_rank
        , created_at
        , (RANK() OVER(Partition by b.user_id Order BY b.created_at)) as "rank"
        , b.id as order_id
  from
  (
    SELECT user_id
          , max(created_at) as "max_order_date"
          , max(rank) as "max_rank"
          , min(created_at) as "min_order_date"
          , min(rank) as "min_rank"
    from (
          SELECT user_id
              , created_at
              , (RANK() OVER(Partition by user_id Order BY created_at)) as "rank"
          from orders
          order by 1, 2
         )
    GROUP BY 1
    order BY 1
  ) a
  JOIN orders b
  on a.user_id = b.user_id
  Order BY 1, 7
) a
JOIN (SELECT id
     , min(days_between_order) as min_days_between_order
from (
  SELECT a.id
       , b.created_at
       , DATEDIFF('day', b.created_at, LEAD(b.created_at, 1) OVER(PARTITION BY a.id ORDER BY b.created_at)) as "days_between_order"
  FROM users a
  FULL OUTER JOIN orders b
  ON a.id = b.user_id
  order by 1
  )
GROUP BY 1
ORDER BY 1
) b
on a.user_id = b.id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 11
ORDER BY 1, 8
       ;;
  }

  measure: count {
    hidden:  yes
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    primary_key: yes
  }

  dimension_group: max_order_date {
    type: time
    sql: ${TABLE}.max_order_date ;;
    timeframes: [date, month, year]
  }

  dimension_group: min_order_date {
    type: time
    sql: ${TABLE}.min_order_date ;;
    timeframes: [date, month, year]
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: max_rank {
    type: number
    sql: ${TABLE}.max_rank ;;
  }

  dimension: min_rank {
    type: number
    sql: ${TABLE}.min_rank ;;
  }

  dimension: is_active_user {
    type: yesno
    sql: ${max_order_date_date} >= GETDATE() - 90 ;;
  }

  dimension:  is_repeat_user {
    type: yesno
    sql: ${max_rank} > 1 ;;
  }

  dimension: days_since_last_order {
    type: number
    sql: DATEDIFF(day, ${max_order_date_date}, GETDATE()) ;;
  }

  dimension: days_between_order {
    type: number
    sql: ${TABLE}.days_between_order ;;
  }

  dimension: min_days_between_order {
    type: number
    sql: ${TABLE}.min_days_between_order ;;
  }

  dimension: has_subsequent_order {
    type: string
    sql: ${TABLE},has_subsequent_order ;;
  }

  measure: avg_days_since_last_order {
    type: average
    sql: ${days_since_last_order} ;;
  }

  set: detail {
    fields: [user_id, max_order_date_date, min_order_date_date, max_rank, min_rank]
  }
}
