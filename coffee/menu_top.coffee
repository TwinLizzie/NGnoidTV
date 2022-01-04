# menu_top.coffee

class top_menuify
  render: =>
    menu_top = $("<div></div>")
    menu_top.attr "id", "menu_top"
    menu_top.attr "class", "menu_top"

    main_menu = $("<a></a>")
    main_menu.attr "id", "main_menu"
    main_menu.attr "class", "main_menu"
    main_menu.attr "href", "javascript:void(0)"

    logo = $("<a></a>")
    logo.attr "id", "site_logo"
    logo.attr "class", "logo pc"
    logo.attr "href", "?Home"

    search_bar = $("<input>")
    search_bar.attr "type", "text"
    search_bar.attr "id", "search_bar"
    search_bar.attr "class", "search_bar"
    search_bar.attr "placeholder", "What are you looking for?"

    search_button = $("<button></button>")
    search_button.attr "id", "search_button"
    search_button.attr "class", "search_button"

    search_icon = $("<div></div>")
    search_icon.attr "id", "search_icon"
    search_icon.attr "class", "search_icon"

    toggle_button = $("<div></div>")
    toggle_button.attr "id", "search_toggle"
    toggle_button.attr "class", "search_toggle"

    toggle_icon = $("<div></div>")
    toggle_icon.attr "id", "search_toggle_icon"
    toggle_icon.attr "class", "search_toggle_icon"

    search_wrap = $("<div></div>")
    search_wrap.attr "id", "search_wrap"
    search_wrap.attr "class", "search_wrap"

    upload_link = $("<a></a>")
    upload_link.attr "id", "upload_link"
    upload_link.attr "class", "upload_link"
    upload_link.attr "href", "?Upload"

    upload_icon = $("<div></div>")
    upload_icon.attr "id", "main_upload"
    upload_icon.attr "class", "main_upload"

    channel_link = $("<a></a>")
    channel_link.attr "id", "usr_channel_link"
    channel_link.attr "class", "usr_channel_link"
    channel_link.attr "href", "?Profile"
    
    channel_icon = $("<div></div>")
    channel_icon.attr "id", "channel_icon"
    channel_icon.attr "class", "channel_icon"

    search_swap = $("<a></a>")
    search_swap.attr "id", "search_swap"
    search_swap.attr "class", "search_swap"
    search_swap.attr "href", "javascript:void(0)"

    search_swap_icon = $("<div></div>")
    search_swap_icon.attr "id", "main_search_swap"
    search_swap_icon.attr "class", "main_search_swap"

    $("#header").html ""
    $("#header").append menu_top
    $("#menu_top").append main_menu
    $("#menu_top").append logo
    $("#search").append search_wrap
    $("#menu_top").append channel_link
    $("#menu_top").append upload_link
    $("#upload_link").html upload_icon
    $("#usr_channel_link").html channel_icon
    $("#menu_top").append search_swap
    $("#search_swap").append search_swap_icon
    $("#search_wrap").append toggle_button
    $("#search_toggle").append toggle_icon
    $("#search_wrap").append search_button
    $("#search_button").append search_icon
    $("#search_wrap").append search_bar
    $("#search_bar").change ->
      if Page.history_state["url"]
        if Page.history_state["url"].indexOf("Home") > -1
          video_lister.get_query()
        else if Page.history_state["url"].indexOf("Latest") > -1
          video_lister.get_query()
        else if Page.history_state["url"].indexOf("Channel") > -1
          video_lister.get_query()
        else if Page.history_state["url"].indexOf("Box") > -1
          videobox.get_query()
        else if Page.history_state["url"].indexOf("Seed") > -1
          seedbox.get_query()
        else
          Page.set_url("?Home")
      else
        video_lister.get_query()  
      
    $("#usr_channel_link").on "click", ->
      Page.nav(this.href)  
    $("#upload_link").on "click", ->
      Page.nav(this.href)
    $("#site_logo").on "click", ->
      Page.nav(this.href)
    $("#main_menu").on "click", ->
      $("#nav").toggle()
    $("#search_toggle").on "click", (e) ->
      $("#search").toggle()
      $("#search").attr "class", "search"
      e.preventDefault()
    $("#search_swap").on "click", (e) ->
      $("#search").toggle()
      $("#search").attr "class", "search_nomove"
      e.preventDefault()

top_menuify = new top_menuify()
