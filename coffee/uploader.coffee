# uploader.coffee

class uploader
  constructor: ->
    file_info = {}

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
      if res == null
        res = {}
      optional_pattern = "(?!data.json)"
      if res.optional is optional_pattern
        cb()
      res.optional = optional_pattern
      Page.cmd "fileWrite", [inner_path, Text.fileEncode(res)], cb

  register_upload: (title, type, description, image_link, file_name, file_size, date_added, cb) =>
    inner_path = "data/users/" + Page.site_info.auth_address + "/data.json"
    Page.cmd "fileGet", [inner_path, false], (res) =>
      if res
        res = JSON.parse(res)
      if res is null or res is undefined
        res = {}
      if res.file is null or res.file is undefined
        res.file = {}
      res.file[file_name] = {title: title, type: type, description: description, image_link: image_link, size: file_size, date_added: date_added}
      Page.cmd "fileWrite", [inner_path, Text.fileEncode(res)], cb

  upload_done: (files, date_added, user_address) =>
    current_account = Page.site_info.cert_user_id        
    anon_accounts = Page.site_info.content.settings.anon_accounts
    if anon_accounts.includes(current_account) == true
      Page.nav("?Latest")      
    else
      Page.set_url("?Editor=" + date_added + "_" + user_address)
      console.log("Upload done!", files)

  upload_file: (files, upload_title, upload_brief, upload_image) =>
    time_stamp = Math.floor(new Date() / 1000)
    console.log("Uploading: " + files.name)

    if files.size > 50 * 1024 * 1024
      current_account = Page.site_info.cert_user_id        
      anon_accounts = Page.site_info.content.settings.anon_accounts
      if anon_accounts.includes(current_account) == true
        Page.cmd("wrapperNotification", ["info", "Maximum file size for anon: 50MB"])
        $("#uploader_title").html "<span>Error! Anon file limits.</span>"
        return false 
      else
        if files.size > 75 * 1024 * 1024
          if window.location.origin is "https://portal.ngnoid.tv"
            Page.cmd("wrapperNotification", ["info", "Maximum proxy file size: 75MB"])
            $("#uploader_title").html "<span>Error! File too large for proxy.</span>"
            return false            
        else if files.size > 10000 * 1024 * 1024
          Page.cmd("wrapperNotification", ["info", "Maximum file size: 10GB"])
          $("#uploader_title").html "<span>Error! 10GB is way too big. Split needed</span>"
          return false        
    if files.size < 0.1 * 1024 * 1024
      Page.cmd("wrapperNotification", ["info", "Minimum file size: 100kb"])
      $("#uploader_title").html "<span>Error! Too small</span>" 
      return false
    if files.name.split(".").slice(-1)[0] not in ["mp4", "m4v", "webm"]
      Page.cmd("wrapperNotification", ["info", "Only mp4, m4v and webm allowed on this site!"])
      $("#uploader_title").html "<span>Error! Mp4, m4v and webm only. Encoding needed</span>" 
      debugger
      return false

    file_info = @file_info = {}
    register_upload = @register_upload
    upload_done = @upload_done
    @check_content_json (res) =>
      file_name = time_stamp + "-" + files.name
      Page.cmd "bigfileUploadInit", ["data/users/" + Page.site_info.auth_address + "/" + file_name, files.size], (init_res) ->
        formdata = new FormData()
        formdata.append(file_name, files)
        req = new XMLHttpRequest()
        @req = req
        file_info = {size: files.size, name: file_name, type: files.type, url: init_res.url}
        req.upload.addEventListener "loadstart", (progress) ->
          console.log "loadstart", arguments
          file_info.started = progress.timeStamp

        req.upload.addEventListener "loadend", ->
          default_type = "standard"
          #default_image = "img/video_empty.png"
          #default_description = "Write description here!"
          console.log("loadend", arguments)
          file_info.status = "done"

          register_upload upload_title, default_type, upload_brief, upload_image, init_res.file_relative_path, files.size, time_stamp, (res) ->
            Page.cmd "siteSign", {inner_path: "data/users/" + Page.site_info.auth_address + "/content.json"}, (res) ->
              Page.cmd "sitePublish", {inner_path: "data/users/" + Page.site_info.auth_address + "/content.json", "sign": false}, (res) ->
                upload_done(files, time_stamp, Page.site_info.auth_address)
        req.upload.addEventListener "progress", (progress) ->
          file_info.speed = 1000 * progress.loaded / (progress.timeStamp - file_info.started)
          file_info.percent = progress.loaded / progress.total
          file_info.loaded = progress.loaded
          file_info.updated = progress.timeStamp

        req.addEventListener "load", ->
          console.log "load", arguments
        req.addEventListener "error", ->
          console.log "error", arguments
        req.addEventListener "abort", ->
          console.log "abort", arguments
        req.withCredentials = true
        req.open "POST", init_res.url
        req.send(formdata)

  render: =>
    video_uploader = $("<div></div>")
    video_uploader.attr "id", "uploader"
    video_uploader.attr "class", "uploader"
    
    uploader_title = $("<div></div>")
    uploader_title.attr "id", "uploader_title"
    uploader_title.attr "class", "uploader_title"
    uploader_title.text "Upload your video here!"

    editor_container = $("<div></div>")
    editor_container.attr "id", "editor_container"
    editor_container.attr "class", "editor_container"

    title_div = $("<div></div>")
    title_div.attr "id", "title_row"
    title_div.attr "class", "upload_editor_row"

    title_label = $("<label></label>")
    title_label.attr "for", "editor_title"
    title_label.attr "class", "editor_input_label"
    title_label.text "Title"

    title_input = $("<input>")
    title_input.attr "id", "editor_title"
    title_input.attr "class", "editor_input"
    title_input.attr "type", "text"
    title_input.attr "name", "editor_title"
    title_input.attr "value", "Write your video title here"

    brief_div = $("<div></div>")
    brief_div.attr "id", "brief_row"
    brief_div.attr "class", "upload_editor_row"

    brief_label = $("<span></span>")
    brief_label.attr "class", "editor_input_label"
    brief_label.text "Description"

    brief_input = $("<textarea>")
    brief_input.attr "id", "editor_brief"
    brief_input.attr "class", "editor_brief_input"
    brief_input.attr "type", "text"
    brief_input.attr "name", "editor_brief"
    brief_input.text "Write your video description here"

    thumbnail_div = $("<div></div>")
    thumbnail_div.attr "id", "thumbnail_row"
    thumbnail_div.attr "class", "upload_editor_row"

    thumbnail_title = $("<span></span>")
    thumbnail_title.attr "id", "editor_input_label"    
    thumbnail_title.attr "class", "editor_input_label"
    #thumbnail_title.text "Thumbnail"

    thumbnail_container = $("<div></div>")
    thumbnail_container.attr "id", "thumbnail_container"
    thumbnail_container.attr "class", "thumbnail_container"

    #thumbnail_image = $("<div></div>")
    #thumbnail_image.attr "id", "thumbnail_preview"
    #thumbnail_image.attr "class", "thumbnail_preview"
    #thumbnail_image.css "background-image", "url('img/video_empty.png')"

    thumbnail_upload_label = $("<label></label>")
    thumbnail_upload_label.attr "id", "thumbnail_preview"    
    thumbnail_upload_label.attr "class", "thumbnail_preview"
    thumbnail_upload_label.attr "for", "thumbnail_upload"
    thumbnail_upload_label.css "background-image", "url('img/video_empty.png')"

    thumbnail_input = $("<input>")
    thumbnail_input.attr "id", "thumbnail_input"
    thumbnail_input.attr "class", "editor_input"
    thumbnail_input.attr "type", "text"
    thumbnail_input.attr "name", "thumbnail_input"
    thumbnail_input.attr "value", "img/video_empty.png"
    thumbnail_input.attr "style", "display: none"

    thumbnail_upload = $("<input>")
    thumbnail_upload.attr "id", "thumbnail_upload"
    thumbnail_upload.attr "type", "file"
    thumbnail_upload.attr "style", "display: none"

    upload_container = $("<div></div>")
    upload_container.attr "id", "upload_container"
    upload_container.attr "class", "upload_container"

    uploader_input = $("<input>")
    uploader_input.attr "id", "uploader_input"
    uploader_input.attr "class", "uploader_input"
    uploader_input.attr "name", "uploader_input"
    uploader_input.attr "type", "file"

    uploader_input_label = $("<label></label>")
    uploader_input_label.attr "id", "uploader_input_label"
    uploader_input_label.attr "class", "uploader_input_label"
    uploader_input_label.attr "for", "uploader_input"    

    upload_file = @upload_file

    $("#main").attr "class", "main_nomenu"
    $("#main").html ""
    donav()
    #$("#nav").hide()
    #$("#main").attr "style", "width: 100%; margin-left: 0px"
    $("#main").append video_uploader
    $("#uploader").append uploader_title
    if window.location.origin is "https://portal.ngnoid.tv"
      $("#uploader").append $("<div style='justify-content: center'><p style='color: white; text-align: center'>Don't want an account yet? Try the Anon <a href='https://anon.ngnoid.tv/kopy.bit/?Upload' target='_blank'> Uploader!</p>")
    $("#uploader").append upload_container
    $("#upload_container").append uploader_input
    $("#upload_container").append uploader_input_label   
    $("#uploader").append editor_container
    $("#editor_container").append title_div
    #$("#title_row").append title_label
    $("#title_row").append title_input
    $("#editor_container").append brief_div
    #$("#brief_row").append brief_label
    $("#brief_row").append brief_input
    $("#uploader").append thumbnail_div
    $("#thumbnail_row").append thumbnail_upload_label
    $("#thumbnail_row").append thumbnail_container
    $("#thumbnail_container").append thumbnail_upload_label
    #$("#editor_container").append thumbnail_upload_label
    $("#editor_container").append thumbnail_upload
    $("#editor_container").append thumbnail_input    

    convert_base64 = @convert_base64    
    $("#thumbnail_upload").on "change", (e) ->
      convert_base64()    
      
    $(document).on "change", ".uploader_input", ->
      editor_title_value = $("#editor_title").val()
      
      if editor_title_value == "Write your video title here"
        Page.cmd "wrapperNotification", ["info", "Add your video title first!"]   
      else     
        if Page.site_info.cert_user_id
          $("#uploader_title").html "<div class='spinner'><div class='bounce1'></div></div>" 
          console.log("[KopyKate: Uploading file.]")
          upload_file(this.files[0], $("#editor_title").val(), $("#editor_brief").val(), $("#thumbnail_input").val())
        else
          Page.cmd "certSelect", [["zeroid.bit"]], (res) =>
            $("#uploader_title").html "<div class='spinner'><div class='bounce1'></div></div>" 
            console.log("KopyKate: Uploading file.")
            upload_file(this.files[0], $("#editor_title").val(), $("#editor_brief").val(), $("#thumbnail_input").val())
        return false

uploader = new uploader()
