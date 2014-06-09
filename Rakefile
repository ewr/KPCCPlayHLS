# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require "rubygems"
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'KPCCPlayHLS'
  app.provisioning_profile = "/Users/eric/Library/MobileDevice/Provisioning Profiles/EAFF4FBD-2996-41A4-A803-2268AC95AC90.mobileprovision"

  app.frameworks += ["CoreMedia","AVFoundation"]
  app.background_modes = [:audio]
end
