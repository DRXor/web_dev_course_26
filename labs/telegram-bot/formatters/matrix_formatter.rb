require '../matrix_library/lib/matrix_library.rb'

class MatrixFormatter
  def self.format(result)
    if result.is_a?(Matrix)
      "```\n#{result.to_s}\n```"
    else
      "`#{result}`"
    end
  end
end