require 'shmexy'

class ShmexyException < RuntimeError
  include Shmexy::MessageGenerator
  attr_accessor :message

  def initialize message = nil
    @message = message
  end

  def to_s
    "Error: #{@message}"
  end
  
  def to_json
    shmexy_error_response( @message ).to_json
  end
end