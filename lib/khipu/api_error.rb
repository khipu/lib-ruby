module Khipu
  class ApiError < StandardError
    attr_accessor :type, :message

    def initialize(type, message)
      @type = type
      @message = message
    end
  end
end