# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require "rubygems"
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'KPCCDebug'
  app.identifier = "is.ewr.KPCCDebug"

  app.entitlements['keychain-access-groups'] = [
      app.seed_id + '.' + app.identifier
  ]

  app.interface_orientations = [:portrait]
  app.frameworks += ["CoreMedia","AVFoundation","MediaPlayer"]
  app.background_modes = [:audio]
end
