# uploader.coffee

class uploader
  constructor: ->
    file_info = {}

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
    Page.set_url("?Editor=" + date_added + "_" + user_address)
    console.log("Upload done!", files)

  upload_file: (files) =>
    time_stamp = Math.floor(new Date() / 1000)
    console.log("Uploading: " + files.name)

    if files.size > 10000 * 1024 * 1024
      Page.cmd("wrapperNotification", ["info", "Maximum file size on this site: 2000MB"])
      $("#uploader_title").html "<span>Error!</span>" 
      return false
    if files.size < 0.1 * 1024 * 1024
      Page.cmd("wrapperNotification", ["info", "Minimum file size: 100kb"])
      $("#uploader_title").html "<span>Error!</span>" 
      return false
    if files.name.split(".").slice(-1)[0] not in ["mp4", "m4v", "webm"]
      Page.cmd("wrapperNotification", ["info", "Only mp4, m4v and webm allowed on this site!"])
      $("#uploader_title").html "<span>Error!</span>" 
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
          default_type = "720p"
          default_image = "img/video_empty.png"
          default_description = "Write description here!"
          console.log("loadend", arguments)
          file_info.status = "done"

          register_upload files.name, default_type, default_description, default_image, init_res.file_relative_path, files.size, time_stamp, (res) ->
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
    $("#uploader").append upload_container
    $("#upload_container").append uploader_input
    $("#upload_container").append uploader_input_label
    $(document).on "change", ".uploader_input", ->
      if Page.site_info.cert_user_id
        $("#uploader_title").html "<div class='spinner'><div class='bounce1'></div></div>" 
        console.log("[KopyKate: Uploading file.]")
        upload_file(this.files[0])
      else
        Page.cmd "certSelect", [["zeroid.bit"]], (res) =>
          $("#uploader_title").html "<div class='spinner'><div class='bounce1'></div></div>" 
          console.log("KopyKate: Uploading file.")
          upload_file(this.files[0])
      return false

uploader = new uploader()
