# profile_editor.coffee

class profile_editor
  constructor: ->
    @render_timeout

  render_box: =>
    $("#profile_editor").text "Welcome to KopyKate BIG!"
    $("#profile_editor_title").text "You are logged in as:"     
    $("#profile_editor_user").text Page.site_info.cert_user_id    

  render: =>
    console.log("[KopyKate: Rendering profile editor.]")  
  
    container_editorbox = $("<div></div>")
    container_editorbox.attr "id", "container_editorbox"
    container_editorbox.attr "class", "editor" 
    
    profile_editorbox = $("<div></div>")
    profile_editorbox.attr "id", "profile_editor"
    profile_editorbox.attr "class", "peditor_divs"
    
    title_peditorbox = $("<div></div>")
    title_peditorbox.attr "id", "profile_editor_title"
    title_peditorbox.attr "class", "peditor_divs"
    
    user_peditorbox = $("<div></div>")
    user_peditorbox.attr "id", "profile_editor_user"
    user_peditorbox.attr "class", "peditor_divs"
  
    $("#main").attr "class", "main_nomenu"
    $("#main").html ""
    donav()
    
    $("#main").append container_editorbox
    $("#container_editorbox").append profile_editorbox
    $("#container_editorbox").append title_peditorbox
    $("#container_editorbox").append user_peditorbox  
    
    $("#profile_editor").text "Loading user info..." 
    
    render_box = @render_box
    render_user = @render_user
    
    @render_timeout = setTimeout ->   
      if Page.site_info  
        if Page.site_info.cert_user_id
          clearTimeout(@render_timeout)
          render_box()
          render_user()
        else
          Page.cmd "certSelect", [["zeroid.bit"]], (res) =>
            console.log "This isn't right."
            clearTimeout(@render_timeout)
            render_box()
            render_user()
    , 1000 
    
profile_editor = new profile_editor()

