require 'fileutils'
require 'pathname'
require 'pebble_receiver/mike_helpers'

module Grack
  class Auth < Rack::Auth::Basic
    include PebbleReceiver::MikeHelpers

    attr_accessor :user, :env

    def call(env)
      @env = env
      @request = Rack::Request.new(env)
      @auth = Request.new(env)

      @env['PATH_INFO'] = @request.path

      auth!
    end

    private

    def auth!
      if @auth.provided?
        return bad_request unless @auth.basic?

        # Authentication with username and password
        login, password = @auth.credentials

        @user = authenticate_user(login, password)

        if @user
          ENV['REMOTE_USER'] = login
          ENV['HOOK_ENV'] = password
          @env['REMOTE_USER'] = @auth.username
        end
      end

      if @user
        if appname
          ensure_repo
          @app.call(env)
        else
          render_not_found
        end
      else
        unauthorized
      end
    end

    def authenticate_user(login, password)
      if get_user({'api_key' => password, 'api_login' => login})
        return {'api_key' => password, 'api_login' => login}
      end

      nil # No user was found
    end

    def appname
      @appname ||= get_app(app_by_path(@request.path_info), user)["name"]
    end

    def app_by_path(path)
      if m = /^\/([\w\.\/-]+)\.git/.match(path).to_a
        m.last
      end
    end

    def ensure_repo
      path = File.join('/tmp/pebble-repos', "#{appname}.git")
      return if File.exist?(path)

      FileUtils.mkdir_p(path, mode: 0755)
      FileUtils.chdir(path) do
        `git init --bare`
      end
      File.open(File.join(path, "hooks", "pre-receive"), "w") do |io|
        io.write prereceivehook
      end
      FileUtils.chmod(0777, File.join(path, "hooks", "pre-receive"))
    end

    def receiver_path
      mefile = Pathname.new(__FILE__).realpath
      File.expand_path("../../receiver", mefile)
    end

    def prereceivehook
      "#!/bin/bash
set -eo pipefail; while read oldrev newrev refname; do
[[ $refname = \"refs/heads/master\" ]] && git archive $newrev | #{receiver_path} \"#{appname}\" \"$newrev\" | sed -$([[ $(uname) == \"Darwin\" ]] && echo l || echo u) \"s/^/\"$'\\e[1G\\e[K'\"/\"
done"
    end

    def render_not_found
      [404, { "Content-Type" => "text/plain" }, ["Not Found"]]
    end
  end
end
