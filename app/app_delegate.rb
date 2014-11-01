class AppDelegate < PM::Delegate
  include PM::Styling

  status_bar true, animation: :none

  def on_load(app, options)
    set_appearance_defaults

    @_home = HomeScreen.new(nav_bar: true)
    @_access = AccessLogScreen.new(nav_bar: true)
    @_error = ErrorLogScreen.new(nav_bar: true)

    open_tab_bar @_home, @_access, @_error
    #@_home = HomeScreen.new(nav_bar: true)
    #open @_home
  end

  def set_appearance_defaults
    UINavigationBar.appearance.barTintColor = hex_color("b24401")
  end
end
