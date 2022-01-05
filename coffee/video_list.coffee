# video_list.coffee

class video_lister
  constructor: ->
    @max_videos=50
    #@last_max_videos=0
    @query_string=""
    @previous_query_string=""
    @counter=1
    @order_by=""
    @global_timeout

  more_videos_yes: =>
    @max_videos+=50
    @counter=1
    @update()

  flush: (mode) =>
    if mode is "all"
      @max_videos=50
      @counter=1
    else
      @counter=1

  get_query: (gotten_query) =>
    @query_string=gotten_query
    if @query_string != @previous_query_string
      @flush("all")
      @update()
      @previous_query_string = @query_string

  linkify: (to, display, tag_class = "", tag_id = "", tag_style = "") =>
    link = "<a id='"+tag_id+"' href='?Video="+to+"'"
    if tag_class and tag_class != ""
      link += " class='"+tag_class+"'"
    if tag_style and tag_style != ""
      link += " style='"+tag_style+"'"
    if tag_id and tag_id != ""
      link += " style='"+tag_id+"'"
    link += ">" + display + "</a>"

    return link 

  link_click: =>
    console.log "Prevented page refresh..."

  seed_click: (inner_path) =>
    Page.cmd "fileNeed", inner_path + "|all", (res) =>
      console.log(res)
    return false

  print_row: (item) =>
    optional_inner_path = "data/users/" + item.directory + "/" + item.file_name
    file_name = item.file_name
    file_seed = 0
    file_peer = 0
    file_is_downloading = false
    optional_size = 0
    
    if item.inner_path
      file_name = item.inner_path.replace /.*\//, ""
      file_seed = item.stats.peer_seed
      file_peer = item.stats.peer
      file_is_downloading = item.stats.is_downloading
      optional_size = item.stats.bytes_downloaded
      
    video_name = item.file_name
    video_title = item.title
    video_size = item.size
    video_brief = item.description
    video_image = item.image_link
    video_date_added = item.date_added
    video_user_address = item.directory
    full_channel_name = item.cert_user_id
    video_channel_name = item.cert_user_id.split("@")[0]

    file_seed_no_null = file_seed || 0

    if optional_size >= video_size
      size_display = Text.formatSize(video_size)
      seed_button_display = false
    else if file_is_downloading
      size_display = Text.formatSize(optional_size) + " / " + Text.formatSize(video_size)
      seed_button_display = false
    else if 0 < optional_size < video_size
      size_display = Text.formatSize(optional_size) + " / " + Text.formatSize(video_size)
      seed_button_display = true
    else
     size_display = Text.formatSize(video_size)
     seed_button_display = true

    video_string = video_date_added + "_" + video_user_address
    video_row_id = "row_" + @counter
    video_link_id = video_string

    elementExists = document.getElementById(video_row_id)
    if elementExists is null

      video_row = $("<div></div>")
      video_row.attr "id", video_row_id
      video_row.attr "class", "video_row"

      video_thumbnail_id = "thumb_" + @counter
      video_thumbnail = $("<a></a>")
      video_thumbnail.attr "id", video_thumbnail_id
      video_thumbnail.attr "class", "video_thumbnail"
      video_thumbnail.css "background-image", "url('"+video_image+"')"
      video_thumbnail.attr "href", "?Video=" + video_string 

      video_info_id = "info_" + @counter
      video_info = $("<div></div>")
      video_info.attr "id", video_info_id
      video_info.attr "class", "video_info"

      video_link = @linkify(video_string, video_title, "video_link", video_string)

      video_peers_id = "peer_" + @counter
      video_peers = $("<div></div>")
      video_peers.attr "id", video_peers_id
      video_peers.attr "class", "video_brief"

      video_seed_button_id = "seed_" + @counter
      video_seed_button = $("<button></button>")
      video_seed_button.attr "id", video_seed_button_id
      video_seed_button.attr "class", "video_seed_button"
      video_seed_button.attr "value", optional_inner_path
      video_seed_button.text "+ SEED"

      video_peers_info = $("<span> Peers " + file_seed_no_null + " / " + file_peer + " - " + size_display + "</span>")

      user_info_id = "user_" + @counter
      user_info = $("<a></a>")
      user_info.attr "id", user_info_id
      user_info.attr "class", "video_brief channel_link"
      user_info.attr "href", "?Channel=" + full_channel_name
      user_info.text video_channel_name.charAt(0).toUpperCase() + video_channel_name.slice(1) + " - " + Time.since(video_date_added)

      video_description = $("<div></div>")
      video_description.attr "id", "video_brief"
      video_description.attr "class", "video_brief"
      video_description.text video_brief

      $("#video_list").append video_row
      $("#" + video_row_id).append video_thumbnail
      $("#" + video_row_id).append video_info
      $("#" + video_info_id).append video_link
      $("#" + video_info_id).append user_info
      $("#" + video_info_id).append video_peers

      if seed_button_display
        $("#" + video_peers_id).append video_seed_button

      $("#" + video_peers_id).append video_peers_info
      $("#" + video_info_id).append video_description            
      $("#" + video_link_id).text video_title
      $("#" + video_link_id).on "click", ->
        Page.nav(this.href)
      $("#" + video_thumbnail_id).on "click", ->
        Page.nav(this.href)
      $("#" + user_info_id).on "click", ->
        Page.nav(this.href)

      seed_click = @seed_click
      flush_page = @flush
      update_page = @update
      $("#" + video_seed_button_id).on "click", ->
        console.log("[NGnoidTV: Seeding - " + this.value + "]")
        seed_click(this.value)
        flush_page()
        update_page()

    @counter = @counter + 1

  query_database: (query, file_limit, order_actual, query_peer) =>

    query_full = "SELECT * FROM file LEFT JOIN json USING (json_id) "+query+" ORDER BY date_added DESC" + file_limit

    #if @query_string != ""
    #  if @order_by == "peer"      
    #    query_peer = false
    
    if query_peer == true
      Page.cmd "optionalFileList", order_actual, (res1) =>
        #if @max_videos > 50
          #$("#video_list").html ""
        $("#more_videos").html "<div class='more_videos text'>More videos!</div>"
        
        stats = {}
        if res1.length > 0
          res1.forEach (row1, index) =>
            optional_name = row1.inner_path.replace /.*\//, ""
            stats[row1.inner_path] = row1
            row1.stats = stats[row1.inner_path]
            row1.file_name = optional_name
            
            Page.cmd "dbQuery", "SELECT * FROM file LEFT JOIN json USING (json_id) WHERE file.file_name='" + optional_name + "'", (res2) =>
              if res2.length > 0           
                row1.title = res2[0].title
                row1.size = res2[0].size
                row1.description = res2[0].description
                row1.image_link = res2[0].image_link
                row1.date_added = res2[0].date_added
                row1.directory = res2[0].directory
                row1.cert_user_id = res2[0].cert_user_id 
              
                @print_row(row1)
        else
          $("#video_list").html "<p style='color: white; margin-left: 10px'>No peers available yet. Stats will show after first download (See 'Airing Now')...</p>"        
          
    else
      Page.cmd "dbQuery", [query_full], (res1) =>
        Page.cmd "optionalFileList", order_actual, (res2) =>
          if @max_videos > 50
            $("#video_list").html ""
          $("#more_videos").html "<div class='more_videos text'>More videos!</div>"
        
          stats = {}
          if res2.length > 0
            for row2, i in res2
              stats[row2.inner_path] = row2            
         
            for row1, j in res1
              row1.inner_path = "data/users/#{row1.directory}/#{row1.file_name}"
              row1.stats = stats[row1.inner_path]
              row1.stats ?= {}
              row1.stats.peer ?= 0
              row1.stats.peer_seed ?= 0
              row1.stats.peer_leech ?= 0
            
            if i == res2.length and j == res1.length
              if @order_by is "peer"
                res1.sort (a,b) ->
                  return Math.min(5, b.stats["peer_seed"]) + b.stats["peer"] - a.stats["peer"] - Math.min(5, a.stats["peer_seed"])
          
              for row3, k in res1
                if @counter < @max_videos
                  @print_row(row3)                                     
          else
            $("#video_list").html "<p style='color: white; margin-left: 10px'>No peers available yet. Stats will show after first download...</p>"
            for row3, k in res1
              if @counter < @max_videos
                @print_row(row3)          
          
  update: =>
    console.log "[KopyKate: Updating video list]"
    
    query = ""

    query_database = @query_database

    max_videos = @max_videos
    file_limit = " LIMIT " + max_videos + ""

    if @order_by is "peer"
      order_actual = {orderby: "peer DESC", filter: "bigfile", address: "18Pfr2oswXvD352BbJvo59gZ3GbdbipSzh", limit: max_videos}
      if @query_string != ""
        query_string_no_space = @query_string.replace /\s/g, "%"
        query = "WHERE file.title LIKE '%" +query_string_no_space+ "%'"
        query_database query, file_limit, order_actual, false        
      else
        query = ""
        query_database query, file_limit, order_actual, true
    else if @order_by is "channel"
      init_url = Page.history_state["url"]
      channel_name = init_url.split("Channel=")[1]
      order_actual = {filter: "", address: "18Pfr2oswXvD352BbJvo59gZ3GbdbipSzh", limit: max_videos}
      query_string_no_space = @query_string.replace /\s/g, "%"
      query = "WHERE cert_user_id='" + channel_name + "' AND file.title LIKE '%" +query_string_no_space+ "%'"
      query_database query, file_limit, order_actual, false      
    else if @order_by is "subbed"
      query_string_no_space = @query_string.replace /\s/g, "%"
      query_timeout = setTimeout ->      
        if Page.site_info
          if Page.site_info.auth_address
            clearTimeout(query_timeout) 
            #query_database = @query_database   
            Page.cmd "dbQuery", ["SELECT * FROM subscription LEFT JOIN json USING (json_id) WHERE directory='" + Page.site_info.auth_address + "'"], (res0) =>
              query = "WHERE "
              i = 0
              for row0, i in res0
                if i < 1
                  query += "directory='" + row0.user_address + "'"
                else
                  query += " OR directory='" + row0.user_address + "'"    
              if i == res0.length
                order_actual = {filter: "", address: "18Pfr2oswXvD352BbJvo59gZ3GbdbipSzh", limit: max_videos}
                query_database query, file_limit, order_actual, false    
      , 1000      
    else
      order_actual = {filter: "", address: "18Pfr2oswXvD352BbJvo59gZ3GbdbipSzh", limit: max_videos}
      if @query_string != ""
        query_string_no_space = @query_string.replace /\s/g, "%"
        query = "WHERE file.title LIKE '%" +query_string_no_space+ "%'"
      else
        query = ""
      query_database query, file_limit, order_actual, false       

  render: =>
    query_value = $("#search_bar").val()
    @query_string=query_value
    video_list = $("<div></div>")
    video_list.attr "id", "video_list"
    video_list.attr "class", "video_list"
    #video_list.html "<div class='spinner'><div class='bounce1'></div></div>"
    
    page_update = @update
    ordering_by = @order_by

    footer = $("<div></div>")
    footer.attr "id", "footer"
    footer.attr "class", "footer"

    get_the_query = @get_query
    ordering_by = @order_by    
    queried_string = @query_string
    globalTimeout = @globalTimeout
    $("#search_bar").on "keyup", ->
      clearTimeout(globalTimeout)
      queried_string = $("#search_bar").val()      
      globalTimeout = setTimeout ->
        $("#video_list").html ""
        queried_string = $("#search_bar").val()      
        get_the_query(queried_string)
      , 1000
    more_videos = $("<a></a>")
    more_videos.attr "id", "more_videos"
    more_videos.attr "class", "more_videos"
    more_videos.attr "href", "javascript:void(0)"

    $("#main").attr "class", "main"
    $("#main").html ""
    donav()
    #$("#main").attr "style", "width: calc(100% - 236.25px); margin-left: 236.25px"
    #$("#nav").show()
    $("#main").append video_list

    $("#main").append footer
    $("#footer").append more_videos
    $("#more_videos").html "<div class='spinner'><div class='bounce1'></div></div>" 

    more_videos_yes = @more_videos_yes
    $("#more_videos").on "click", ->
      $("#more_videos").html "<div class='spinner'><div class='bounce1'></div></div>" 
      more_videos_yes()     
  
    @update()

video_lister = new video_lister()
