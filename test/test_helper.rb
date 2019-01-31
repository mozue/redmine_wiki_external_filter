require "test_helper"

module WikiExternalFilterTestHelper
  def fixture_path(*components)
    File.join(__dir__, "fixtures", *components)
  end
end
