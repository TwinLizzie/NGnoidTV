# editor.coffee

class editor
  convert_base64: =>
    max_size = 1024 * 25
    thumbnail_upload = $("#thumbnail_upload").prop("files")[0]

    if thumbnail_upload && thumbnail_upload.size < max_size
      convertImage(thumbnail_upload)
    else
      Page.cmd "wrapperNotification", ["info", "Max image size: 25kb (Tip: use GIMP or online compression tools to reduce resolution/quality!)"]
      debugger
      return false

  check_content_json: (cb) =>
    inner_path = "data/users/" + Page.site_info.auth_address + "/content.json"
    Page.cmd "fileGet", [inner_path, false], (res) =>
      if res
        res = JSON.parse(res)
      res ?= {}
      optional_pattern = "(?!data.json)"
      if res.optional == optional_pattern
        return cb()

      res.optional = optional_pattern
      Page.cmd "fileWrite", [inner_path, Text.fileEncode(res)], cb

  register_info: (v_file, v_date, v_size, v_title, v_description, v_image, cb) =>
    inner_path = "data/users/" + Page.site_info.auth_address + "/data.json"
    Page.cmd "fileGet", [inner_path, false], (res) =>
      if res
        res = JSON.parse(res)
      if res == null
        res = {}
      if res.file == null
        res.file = {}
      res.file[v_file] = {title: v_title, date_added: v_date, size: v_size, description: v_description, image_link: v_image}
      Page.cmd "fileWrite", [inner_path, Text.fileEncode(res)], cb

  save_info: (v_file, v_date, v_size, v_title, v_description, v_image) =>
    register_info = @register_info

    @check_content_json (res) =>
      register_info v_file, v_date, v_size, v_title, v_description, v_image, (res) =>
        Page.cmd "siteSign", {inner_path: "data/users/" + Page.site_info.auth_address + "/content.json"}, (res) ->
          Page.cmd "sitePublish", {inner_path: "data/users/" + Page.site_info.auth_address + "/content.json", "sign": false}, (res) ->
            Page.set_url("?Box")

  render: =>

    console.log("[KopyKate: Rendering editor.]")
    init_url = Page.history_state["url"]
    real_url = init_url.split("Editor=")[1]
    
    date_added = real_url.split("_")[0]
    user_address = real_url.split("_")[1]

    editorbox = $("<div></div>")
    editorbox.attr "id", "editor"
    editorbox.attr "class", "editor"

    query = "SELECT * FROM file LEFT JOIN json USING (json_id) WHERE date_added='" + date_added + "' AND directory='" + user_address + "'"
    Page.cmd "dbQuery", [query], (res) =>

      if res.length is 0
        $("#editor").html "<span>Error: No such video found!</span>"
      else
        my_row = res[0]
        file_name = my_row['file_name']

        video_title = my_row['title']
        video_type = my_row['type']
        video_image = my_row['image_link']
        video_description = my_row['description']
        video_date_added = my_row['date_added']
        video_size = my_row['size']

        user_directory = my_row['directory']
     
        if user_directory is Page.site_info.auth_address

          editor_container = $("<div></div>")
          editor_container.attr "id", "editor_container"
          editor_container.attr "class", "editor_container"
 
          editor_submit = $("<button></button>")
          editor_submit.attr "id", "editor_submit_button"
          editor_submit.attr "class", "standard_button"
          editor_submit.text "PUBLISH"

          title_div = $("<div></div>")
          title_div.attr "id", "title_row"
          title_div.attr "class", "editor_row"

          title_label = $("<label></label>")
          title_label.attr "for", "editor_title"
          title_label.attr "class", "editor_input_label"
          title_label.text "Title"

          title_input = $("<input>")
          title_input.attr "id", "editor_title"
          title_input.attr "class", "editor_input"
          title_input.attr "type", "text"
          title_input.attr "name", "editor_title"
          title_input.attr "value", video_title

          brief_div = $("<div></div>")
          brief_div.attr "id", "brief_row"
          brief_div.attr "class", "editor_row"

          brief_label = $("<span></span>")
          brief_label.attr "class", "editor_input_label"
          brief_label.text "Description"

          brief_input = $("<textarea>")
          brief_input.attr "id", "editor_brief"
          brief_input.attr "class", "editor_brief_input"
          brief_input.attr "type", "text"
          brief_input.attr "name", "editor_brief"
          brief_input.text video_description

          thumbnail_div = $("<div></div>")
          thumbnail_div.attr "id", "thumbnail_row"
          thumbnail_div.attr "class", "editor_row"

          thumbnail_title = $("<span></span>")
          thumbnail_title.attr "class", "editor_input_label"
          thumbnail_title.text "Thumbnail"

          thumbnail_container = $("<div></div>")
          thumbnail_container.attr "id", "thumbnail_container"
          thumbnail_container.attr "class", "thumbnail_container"

          thumbnail_image = $("<div></div>")
          thumbnail_image.attr "id", "thumbnail_preview"
          thumbnail_image.attr "class", "thumbnail_preview"
          thumbnail_image.css "background-image", "url('" + video_image + "')"

          thumbnail_input = $("<input>")
          thumbnail_input.attr "id", "thumbnail_input"
          thumbnail_input.attr "class", "editor_input"
          thumbnail_input.attr "type", "text"
          thumbnail_input.attr "name", "thumbnail_input"
          thumbnail_input.attr "value", video_image
          thumbnail_input.attr "style", "display: none"

          thumbnail_upload_label = $("<label></label>")
          thumbnail_upload_label.attr "class", "standard_button"
          thumbnail_upload_label.attr "for", "thumbnail_upload"
          thumbnail_upload_label.text "UPLOAD IMAGE"

          thumbnail_upload = $("<input>")
          thumbnail_upload.attr "id", "thumbnail_upload"
          thumbnail_upload.attr "type", "file"
          thumbnail_upload.attr "style", "display: none"

          $("#editor").append editor_container
          $("#editor_container").append title_div
          $("#title_row").append title_label
          $("#title_row").append title_input
          $("#editor_container").append brief_div
          $("#brief_row").append brief_label
          $("#brief_row").append brief_input
          $("#editor_container").append thumbnail_div
          $("#thumbnail_row").append thumbnail_title
          $("#thumbnail_row").append thumbnail_container
          $("#thumbnail_container").append thumbnail_image
          $("#editor_container").append editor_submit
          $("#editor_container").append thumbnail_upload_label
          $("#editor_container").append thumbnail_upload
          $("#editor_container").append thumbnail_input

          convert_base64 = @convert_base64
          $("#thumbnail_upload").on "change", (e) ->
            convert_base64()

          save_info = @save_info
          $("#editor_submit_button").on "click", (e) ->
            save_info file_name, video_date_added, video_size, $("#editor_title").val(), $("#editor_brief").val(), $("#thumbnail_input").val()
            e.preventDefault() 
        else
          $("#editor").html "<span>Error: Permission denied!</span>"

    $("#main").attr "class", "main_nomenu"
    $("#main").html ""
    donav()
    #$("#nav").hide()
    #$("#main").attr "style", "width: 100%; margin-left: 0px"
    $("#main").append editorbox

editor = new editor()
