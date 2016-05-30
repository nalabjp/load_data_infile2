module Support
  module Subject
    def subject(&blk)
      if block_given?
        @__subject = blk
      else
        @__subject_result ||= @__subject.call
      end
    end
  end
end

Test::Unit::TestCase.include Support::Subject
