# seedbox.coffee

class seedbox
  constructor: ->
    @max_videos=15
    @query_string=""
    @counter=1

  more_videos_yes: =>
    @max_videos+=15
    @counter=1
    @update()

  flush: (mode) =>
    if mode is "all"
      @max_videos=15
      @counter=1
    else
      @counter=1

  get_query: =>
    query_value = $("#search_bar").val()
    @query_string=query_value
    @flush("all")
    @update()

  delete_optional_files: (form) =>
    values = []
    bigfiles = form.bigfile
    
    for bigfile_row, i in bigfiles
      if bigfile_row.checked
        values.push(bigfile_row.value)

    for value_row, i in values
      Page.cmd "optionalFileDelete", value_row
      Page.cmd "optionalFileDelete", value_row + ".piecemap.msgpack"
      console.log("[KopyKate: Deleted optional file " + value_row + "]")
    @flush("all")
    @update()
      

  update: =>
    console.log "[KopyKate: Retrieving seedbox]"
    query_string_no_space = @query_string.replace /\s/g, "%"
    query = "WHERE file.title LIKE '%" +query_string_no_space+ "%'"
    
    Page.cmd "dbQuery", ["SELECT * FROM file LEFT JOIN json USING (json_id) "+query+" ORDER BY date_added DESC"], (res1) =>
      Page.cmd "optionalFileList", {filter: "downloaded,bigfile", limit: 1000}, (res2) =>

        $("#seedbox_actual_list").html ""
        $("#more_videos").html "<div class='more_videos text'>More videos!</div>"

        current_account = Page.site_info.cert_user_id
        anon_accounts = Page.site_info.content.settings.anon_accounts

        if res2.length > 0 && anon_accounts.includes(current_account) is false 

          for row1, i in res1
            for row2, j in res2
              optional_path = row2['inner_path']
              file_name = row2['inner_path'].replace /.*\//, ""
              file_seed = row2['peer_seed']
              file_peer = row2['peer']
              file_size = row2['bytes_downloaded']
              video_name = row1['file_name']
              video_title = row1['title']
              video_brief = row1['description']
              video_image = row1['image_link']
              video_date_added = row1['date_added']
              video_user_address = row1['directory']
              video_size = row1['size']

              if video_name is file_name and @counter < @max_videos
                file_seed_no_null = file_seed || 0
              
                if file_size >= video_size
                  text_display = "DONE " + Text.formatSize(video_size)
                else
                  text_display = Text.formatSize(file_size) + " / " + Text.formatSize(video_size)

                video_string = video_date_added + "_" + video_user_address
                video_row_id = "seedrow_" + @counter
                video_link_id = video_string

                video_row = $("<div></div>")
                video_row.attr "id", video_row_id
                video_row.attr "class", "seedbox_row"
              
                video_checkbox_id = "vcheck_" + @counter
                video_checkbox = $("<input>")
                video_checkbox.attr "id", video_checkbox_id
                video_checkbox.attr "type", "checkbox"
                video_checkbox.attr "name", "bigfile"
                video_checkbox.attr "value", optional_path
                video_checkbox.attr "style", "display: none"

                checkbox_label_id = "vcheck_label_" + @counter
                checkbox_label = $("<label></label>")
                checkbox_label.attr "id", checkbox_label_id
                checkbox_label.attr "class", "checkbox_container"

                checkmark_span = $("<span></span>")
                checkmark_span.attr "class", "checkmark"
              
                megabytes = $("<span></span>")
                megabytes.attr "class", "video_link seedbox_bytes"
                megabytes.text text_display

                video_link_id = "link_" + video_string
                video_link = $("<a></a>")
                video_link.attr "id", video_link_id
                video_link.attr "class", "video_link edit_link"
                video_link.attr "href", "?Video=" + video_string
                video_link.text video_title

                $("#seedbox_actual_list").append video_row
                $("#" + video_row_id).append checkbox_label
                $("#" + checkbox_label_id).append video_checkbox
                $("#" + checkbox_label_id).append checkmark_span
                $("#" + video_row_id).append megabytes
                $("#" + video_row_id).append video_link
                $("#" + video_link_id).on "click", ->
                  Page.nav(this.href)
                @counter = @counter + 1
        else 
          $("#seedbox_actual_list").html "<p style='color: white; margin-left: 10px'>Oops! Nothing to see here... (Yet?)</p>"  

  render: =>
    query_value = $("#search_bar").val()
    @query_string=query_value
    seedbox_div = $("<div></div>")
    seedbox_div.attr "id", "seedbox"
    seedbox_div.attr "class", "seedbox"
    #seedbox_div.html "<div class='spinner'><div class='bounce1'></div><div class='bounce2'></div><div class='bounce3'></div></div>"

    seedbox_form = $("<form></form>")
    seedbox_form.attr "id", "seedbox_form"

    seedbox_actual_list = $("<div></div>")
    seedbox_actual_list.attr "id", "seedbox_actual_list"

    checkbox_buttons = $("<div></div>")
    checkbox_buttons.attr "id", "checkbox_buttons"

    footer = $("<div></div>")
    footer.attr "id", "footer"
    footer.attr "class", "footer"

    more_videos = $("<a></a>")
    more_videos.attr "id", "more_videos"
    more_videos.attr "class", "more_videos"
    more_videos.attr "href", "javascript:void(0)"

    $("#main").attr "class", "main"
    $("#main").html ""
    donav()
    #$("#main").attr "style", "width: calc(100% - 236.25px); margin-left: 236.25px"
    #$("#nav").show()
    $("#main").append seedbox_div
    $("#seedbox").append seedbox_form

    $("#seedbox_form").append checkbox_buttons
    $("#checkbox_buttons").html "<label class='file_button' for='deselect_seed'>DESELECT</label><label class='file_button' for='delete_seed'>DELETE</label><input type='reset' id='deselect_seed' value='Deselect' style='display: none'><input type='submit' id='delete_seed' value='Delete' style='display: none'>"
    $("#seedbox_form").append seedbox_actual_list

    $("#main").append footer
    $("#footer").append more_videos
    $("#more_videos").html "<div class='spinner'><div class='bounce1'></div></div>" 

    more_videos_yes = @more_videos_yes
    $("#more_videos").on "click", ->
      $("#more_videos").html "<div class='spinner'><div class='bounce1'></div></div>" 
      more_videos_yes()
    
    delete_optional_files = @delete_optional_files
    $("#seedbox_form").on "submit", (e) ->
      delete_optional_files(this)
      e.preventDefault()

    @update()

seedbox = new seedbox()
