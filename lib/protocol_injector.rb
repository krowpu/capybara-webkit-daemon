# frozen_string_literal: true

##
# Protocol injector is a transport layer meta-protocol
# which can combine multiple transport layer protocols
# in a single data stream.
#
class ProtocolInjector
  def initialize
    @handlers = []
  end

  def call(s)
    @handlers.each do |handler|
      return '' if s.empty?
      s = handler.(s)
    end
    s
  end

  def inject(handler)
    raise TypeError, 'handler must respond to #call'           unless handler.respond_to? :call
    raise TypeError, "handler's #call must return a #{String}" unless handler.('').is_a? String

    @handlers << handler
    self
  end
end
