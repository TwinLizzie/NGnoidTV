class Page extends ZeroFrame
  constructor: ->
    super()
    already_rendered=false

  render: =>
    @already_rendered=true
    top_menuify.render()
    left_menuify.render()
    if base.href.indexOf("?") is -1
      @route("", "home")
      @state = {};
      @state.page = "home"
    else
      url = base.href.replace /.*?\?/, ""
      @history_state["url"] = url

      if base.href.indexOf("Video") > -1
        @route(url, "video")
        @state = {};
        @state.page = "video"
      else if base.href.indexOf("Upload") > -1
        @route(url, "upload")
        @state = {};
        @state.page = "upload"
      else if base.href.indexOf("Editor") > -1
        @route(url, "editor")
        @state = {};
        @state.page = "editor"
      else if base.href.indexOf("Profile") > -1
        @route(url, "profile")
        @state = {};
        @state.page = "profile"
      else if base.href.indexOf("Box") > -1
        @route(url, "box")
        @state = {};
        @state.page = "box"
      else if base.href.indexOf("Seed") > -1
        @route(url, "seed")
        @state = {};
        @state.page = "seedbox"
      else if base.href.indexOf("Latest") > -1
        @route(url, "latest")
        @state = {};
        @state.page = "latest"
      else if base.href.indexOf("Channel") > -1
        @route(url, "channel")
        @state = {};
        @state.page = "channel"
      else if base.href.indexOf("Subbed") > -1
        @route(url, "subbed")
        @state = {};
        @state.page = "subbed"        
      else if base.href.indexOf("Home") > -1
        @route("", "home")
        @state = {};
        @state.page = "home"

    @on_site_info = new Promise()
    @on_loaded = new Promise()

  set_site_info: (site_info) =>
    @site_info = site_info

  update_site_info: =>
    @cmd "siteInfo", {}, (site_info) =>
      @address = site_info.address
      @set_site_info(site_info)
      @on_site_info.resolve()

  onOpenWebsocket: =>
    @update_site_info()
    if @already_rendered
      console.log("[KopyKate: Websocket opened]")
    else
      @render()
      console.log("[KopyKate: Websocket opened]")

  onRequest: (cmd, params) =>
    console.log("[KopyKate: Request]")
    if cmd == "setSiteInfo"
      @set_site_info(params)
      #if params.event?[0] in ["file_done", "file_delete", "peernumber_updated"]
      #  RateLimit 1000, =>
      #    console.log("[KopyKate: Something changed!]")
          #video_lister.flush()
          #video_lister.update()
    else if cmd is "wrapperPopState"
      if params.state
        if !params.state.url
          params.state.url = params.href.replace /.*\?/, ""
        @on_loaded.resolved = false
        document.body.className = ""
        window.scroll(window.pageXOffset, params.state.scrollTop or 0)

        @route(params.state.url || "")

  project_this: (mode) =>
    console.log("[KopyKate: Mode (" + mode + ")]")
    if mode is "home"
      video_lister.order_by="peer"
      video_lister.max_videos=50
      video_lister.counter=1
      video_lister.render()
    else if mode is "latest"
      video_lister.order_by="date"
      video_lister.max_videos=50
      video_lister.counter=1
      video_lister.render()
    else if mode is "subbed"
      video_lister.order_by="subbed"
      video_lister.max_videos=50
      video_lister.counter=1
      video_lister.render()      
    else if mode is "channel"
      video_lister.order_by="channel"
      video_lister.max_videos=50
      video_lister.counter=1
      video_lister.render()
    else if mode is "video"
      video_playing.render()
    else if mode is "upload"
      uploader.render()
    else if mode is "editor"
      editor.render()
    else if mode is "profile"
      profile_editor.render()
    else if mode is "box"
      videobox.max_videos=15
      videobox.counter=1
      videobox.render()
    else if mode is "seed"
      seedbox.max_videos=15
      seedbox.counter=1
      seedbox.render()

  route: (query) =>
    query = JSON.stringify(query)
    console.log "[KopyKate: Routing (" + query + ")]"

    if query.indexOf("Video") > -1
      @project_this("video")
    else if query.indexOf("Upload") > -1
      @project_this("upload")
    else if query.indexOf("Editor") > -1
      @project_this("editor")
    else if query.indexOf("Profile") > -1
      @project_this("profile")
    else if query.indexOf("Box") > -1
      @project_this("box")
    else if query.indexOf("Seed") > -1
      @project_this("seed")
    else if query.indexOf("Latest") > -1
      @project_this("latest")
    else if query.indexOf("Channel") > -1
      @project_this("channel")
    else if query.indexOf("Subbed") > -1
      @project_this("subbed")      
    else
      @project_this("home")

  set_url: (url) =>
    url = url.replace /.*?\?/, ""
    console.log "[KopyKate: Setting url (FROM " + @history_state["url"] + " TO -> " + url + ")]"
    if @history_state["url"] is url
      return false
    @history_state["url"] = url
    @cmd "wrapperPushState", [@history_state, "", url]

    @route(url)
    return false

  nav: (identifier) =>
    if identifier is null
      return true
    else
      console.log "save scrollTop", window.pageYOffset
      @history_state["scrollTop"] = window.pageYOffset
      @cmd "wrapperReplaceState", [@history_state, null]
      window.scroll(window.pageXOffset, 0)
      @history_state["scroll_top"] = 0
      @on_loaded.resolved = false
      document.body.className = ""
      @set_url(identifier)
      return false

Page = new Page()
