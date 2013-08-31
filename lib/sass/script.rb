# Contains extensions of Sass::Script::Nodes to add support for accessing
# various parts of the parse tree not provided out-of-the-box.
module Sass::Script
  class Variable
    # When accessing keyword arguments, the Sass parser treats the underscored
    # name as canonical. Since this only matters during the compilation step, we
    # can safely override the behaviour to return the original name.
    def underscored_name
      @name
    end
  end
end
