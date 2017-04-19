view: products {
  sql_table_name: public.products ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;

    link: {
      label: "Website"
      url: "http://www.google.com/search?q={{ value | encode_uri }}+clothes&btnI"
      icon_url: "http://www.google.com/s2/favicons?domain=www.{{ value | encode_uri }}.com"
    }

    link: {
      label: "Facebook"
      url: "http://www.google.com/search?q=site:facebook.com+{{ value | encode_uri }}+clothes&btnI"
      icon_url: "https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico"
    }

    link: {
      label: "Brand Comparison Dashboard"
      url: "https://sandbox.dev.looker.com/dashboards/224?Brand%20Select={{ value | encode_uri }}&Brand%20Except=-{{ value | encode_uri }}&filter_config=%7B%22Brand%20Select%22:%5B%7B%22type%22:%22%3D%22,%22values%22:%5B%7B%22constant%22:%22{{ value | encode_uri }}%22%7D,%7B%7D%5D,%22id%22:0%7D%5D,%22Brand%20Except%22:%5B%7B%22type%22:%22!%3D%22,%22values%22:%5B%7B%22constant%22:%22{{ value | encode_uri }}%22%7D,%7B%7D%5D,%22id%22:1%7D%5D"
#             https://sandbox.dev.looker.com/dashboards/224?Brand%20Select=                        &Brand%20Except=-                        &Category=Accessories             {{ products.category.rendered_value }}              &filter_config=%7B%22Brand%20Select%22:%5B%7B%22type%22:%22%3D%22,%22values%22:%5B%7B%22constant%22:%22                        %22%7D,%7B%7D%5D,%22id%22:0%7D%5D,%22Brand%20Except%22:%5B%7B%22type%22:%22!%3D%22,%22values%22:%5B%7B%22constant%22:%22                        %22%7D,%7B%7D%5D,%22id%22:1%7D%5D,%22Category%22:%5B%7B%22type%22:%22%3D%22,%22values%22:%5B%7B%22constant%22:%22Accessories                           %22%7D,%7B%7D%5D,%22id%22:2%7D%5D%7D
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    drill_fields: [brand, orders.nonactive_count]
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}.item_name ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  filter: brand_select {
    suggest_dimension: brand
  }

  dimension: brand_comparitor {
    sql: CASE WHEN {% condition brand_select %} ${brand} {% endcondition %}
         THEN ${brand}
         ELSE 'Rest of Population'
         END;;
  }

  measure: count {
    type: count
    drill_fields: [id, item_name, inventory_items.count, product_facts.count]
  }
}
