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

  app.interface_orientations = [:portrait]
  app.frameworks += ["CoreMedia","AVFoundation"]
  app.background_modes = [:audio]
end
