# frozen_string_literal: true

# This file requires all library files for proper coverage calculation.

require 'scrapod/server'

require 'capybara/webkit/daemon/redis'

require 'capybara/webkit/daemon/messaging'
require 'capybara/webkit/daemon/messaging/inserter'
require 'capybara/webkit/daemon/messaging/extractor'

require 'capybara/webkit/daemon/binary_messaging'
require 'capybara/webkit/daemon/binary_messaging/inserter'
require 'capybara/webkit/daemon/binary_messaging/extractor'

require 'capybara/webkit/daemon/server/arguments'
require 'capybara/webkit/daemon/server/capybara_webkit_protocol_parser'
require 'capybara/webkit/daemon/server/client'
require 'capybara/webkit/daemon/server/client_to_server_wrapper'
require 'capybara/webkit/daemon/server/environments'
require 'capybara/webkit/daemon/server/link'
require 'capybara/webkit/daemon/server/listener'
require 'capybara/webkit/daemon/server/logger'
require 'capybara/webkit/daemon/server/pid_file'
require 'capybara/webkit/daemon/server/process'
require 'capybara/webkit/daemon/server/server_to_client_wrapper'
require 'capybara/webkit/daemon/server/signal_handler'
require 'capybara/webkit/daemon/server/stage'
require 'capybara/webkit/daemon/server/streams'
require 'capybara/webkit/daemon/server/wrapper'

require 'good_option_parser'
require 'good_option_parser/formatter'
require 'good_option_parser/option'
require 'good_option_parser/options'
require 'good_option_parser/parser'

require 'protocol_injector'
