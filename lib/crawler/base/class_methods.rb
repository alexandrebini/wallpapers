module Crawler
  module ClassMethods
    def start!
      self.new.start!
    end
  end
end