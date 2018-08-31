require "singleton"

class IdStore
  include Singleton

  def initialize
    @start_at = 1
  end

  def id
    result = @start_at
    @start_at+=1
    result
  end
end



