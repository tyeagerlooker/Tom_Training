connection: "red_look"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

# explore: inventory_items {
#   join: products {
#     type: left_outer
#     sql_on: ${inventory_items.product_id} = ${products.id} ;;
#     relationship: many_to_one
#   }
# }

map_layer: us_states_1 {
  url: "https://raw.githubusercontent.com/jgoodall/us-maps/master/topojson/state.topo.json"
}

explore: order_items {
  fields: [ALL_FIELDS*, -user_order_date_rank.user_id]
  join: orders {
    type: left_outer
    sql_on: ${order_items.order_id} = ${orders.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: user_order_date_rank {
    type: left_outer
    sql_on: ${orders.id} = ${user_order_date_rank.order_id} ;;
    relationship: one_to_one
    view_label: "User Order Fact"
  }

  join: user_order_fact {
    type: left_outer
    sql_on: ${users.id} = ${user_order_fact.user_id} ;;
    relationship: one_to_one
  }

  join: retention_cohort_analysis {
    type: left_outer
    sql_on: ${users.id} = ${retention_cohort_analysis.user_id};;
    relationship: one_to_many
  }

}

# explore: orders {
#   join: users {
#     type: left_outer
#     sql_on: ${orders.user_id} = ${users.id} ;;
#     relationship: many_to_one
#   }
# }

# explore: product_facts {
#   join: products {
#     type: left_outer
#     sql_on: ${product_facts.product_id} = ${products.id} ;;
#     relationship: many_to_one
#   }
# }

# explore: products {}

explore: users {}
