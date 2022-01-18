# menu_left.coffee

class left_menuify
  render: =>
    menu_left = $("<div></div>")
    menu_left.attr "id", "menu_left"
    menu_left.attr "class", "menu_left"

    menu_left_items = $("<ul></ul>")
    menu_left_items.attr "id", "menu_left_items"
    menu_left_items.attr "class", "menu_left_items"

    item_head_version = $("<li></li>")
    item_head_version.attr "id", "item_head_version"
    item_head_version.attr "class", "list_item li_head"
    item_head_version.text "BETA v0.3.07"

    item_home = $("<li></li>")
    item_home.attr "id", "item_home"
    item_home.attr "class", "list_item li_home"

    item_home_link = $("<a></a>")
    item_home_link.attr "id", "item_home_link"
    item_home_link.attr "class", "item_link"
    item_home_link.attr "href", "?Home"
    item_home_link.text "Home"

    item_latest = $("<li></li>")
    item_latest.attr "id", "item_latest"
    item_latest.attr "class", "list_item li_latest"

    item_latest_link = $("<a></a>")
    item_latest_link.attr "id", "item_latest_link"
    item_latest_link.attr "class", "item_link"
    item_latest_link.attr "href", "?Latest"
    item_latest_link.text "Airing Now"

    item_subbed = $("<li></li>")
    item_subbed.attr "id", "item_subbed"
    item_subbed.attr "class", "list_item li_subbed"

    item_subbed_link = $("<a></a>")
    item_subbed_link.attr "id", "item_subbed_link"
    item_subbed_link.attr "class", "item_link"
    item_subbed_link.attr "href", "?Subbed"
    item_subbed_link.text "Subscribed"

    item_videobox = $("<li></li>")
    item_videobox.attr "id", "item_videobox"
    item_videobox.attr "class", "list_item li_videobox"

    item_videobox_link = $("<a></a>")
    item_videobox_link.attr "id", "item_videobox_link"
    item_videobox_link.attr "class", "item_link"
    item_videobox_link.attr "href", "?Box"
    item_videobox_link.text "VideoBox"

    item_seedbox = $("<li></li>")
    item_seedbox.attr "id", "item_seedbox"
    item_seedbox.attr "class", "list_item li_seedbox"

    item_seedbox_link = $("<a></a>")
    item_seedbox_link.attr "id", "item_seedbox_link"
    item_seedbox_link.attr "class", "item_link"
    item_seedbox_link.attr "href", "?Seed"
    item_seedbox_link.text "SeedBox"

    item_source = $("<li></li>")
    item_source.attr "id", "item_source"
    item_source.attr "class", "list_item li_source"

    item_source_link = $("<a></a>")
    item_source_link.attr "id", "item_source_link"
    item_source_link.attr "class", "item_link"
    if window.location.origin is "https://portal.ngnoid.tv"
      item_source_link.attr "href", "https://github.com/TwinLizzie/ngnoidtv"
    else
      item_source_link.attr "href", "http://127.0.0.1:43110/12NptcFqnsxiydK4W8VLK6EwjpbZS3bTHS"
    item_source_link.text "Source Code"

    $("#nav").html ""
    $("#nav").append menu_left
    $("#menu_left").append menu_left_items
    $("#menu_left_items").append item_head_version
    $("#menu_left_items").append item_home
    $("#item_home").append item_home_link
    $("#menu_left_items").append item_latest
    $("#item_latest").append item_latest_link
    $("#menu_left_items").append item_subbed
    $("#item_subbed").append item_subbed_link
    $("#menu_left_items").append item_videobox
    $("#item_videobox").append item_videobox_link
    $("#menu_left_items").append item_seedbox
    $("#item_seedbox").append item_seedbox_link
    $("#menu_left_items").append item_source
    $("#item_source").append item_source_link
    $("#item_home_link").on "click", ->
      Page.nav(this.href)
    $("#item_latest_link").on "click", ->
      Page.nav(this.href)
    $("#item_videobox_link").on "click", ->
      Page.nav(this.href)
    $("#item_seedbox_link").on "click", ->
      Page.nav(this.href)
    $("#item_subbed_link").on "click", ->
      Page.nav(this.href)

left_menuify = new left_menuify()
