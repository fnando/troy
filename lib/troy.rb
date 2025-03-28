# frozen_string_literal: true

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

require "builder"
require "i18n"
require "redcarpet"
require "redcarpet-abbreviations"
require "sass"
require "sass-globbing"
require "sprockets"
require "thor"
require "thor/group"
require "rack"
require "rackup/handler"
require "uglifier"
require "html_press"

level = $VERBOSE
$VERBOSE = nil
require "rouge"
require "rouge/plugins/redcarpet"
$VERBOSE = level

require "cgi"
require "fileutils"
require "forwardable"
require "ostruct"
require "pathname"
require "yaml"

require "troy/cli"
require "troy/configuration"
require "troy/context"
require "troy/embedded_ruby"
require "troy/extension_matcher"
require "troy/generator"
require "troy/helpers"
require "troy/markdown"
require "troy/meta"
require "troy/page"
require "troy/xml"
require "troy/server"
require "troy/site"
require "troy/version"
require "troy/hacks"
