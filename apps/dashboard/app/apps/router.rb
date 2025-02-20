class Router

  # Return a Router [SysRouter, UsrRouter or DevRouter] based off
  # of the input token. Returns nil if nothing is parsed correctly.
  #
  # return [SysRouter, UsrRouter or DevRouter]
  def self.router_from_token(token)
    type, *app = token.split("/")
    case type
    when "dev"
      name, = app
      DevRouter.new(name)
    when "usr"
      owner, name, = app
      UsrRouter.new(name, owner)
    when "sys"
      name, = app
      SysRouter.new(name)
    end
  end

  # All the configured "Pinned Apps". Returns an array of unique and already rejected apps
  # that may be problematic (inaccessible or idden and so on). Should at least return an
  # an empty array.
  #
  # @return [FeaturedApp]
  def self.pinned_apps(tokens, all_apps)
    @pinned_apps ||= tokens.to_a.each_with_object([]) do |token, pinned_apps|
      pinned_apps.concat pinned_apps_from_token(token, all_apps)
    end.uniq do |app|
      app.token.to_s
    end
  end

  private

  def self.pinned_apps_from_token(token, all_apps)
    matcher = TokenMatcher.new(token)

    all_apps.select do |app|
      matcher.matches_app?(app)
    end.each_with_object([]) do |app, apps|
      if app.has_sub_apps?
        apps.concat(featured_apps_from_sub_app(app, matcher))
      else
        apps.append(FeaturedApp.from_ood_app(app))
      end
    end
  end

  def self.featured_apps_from_sub_app(app, matcher)
    app.sub_app_list.each_with_object([]) do |sub_app, apps|
      apps.append(FeaturedApp.from_ood_app(app, token: sub_app.token)) if matcher.matches_app?(sub_app)
    end
  end
end
