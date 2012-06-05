module Foo
  def self.included(base)
    puts base
    puts base::NAME
  end

end

class Bar
  NAME = 'some name'
  include Foo

end
