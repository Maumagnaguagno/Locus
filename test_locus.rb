require 'test/unit'
require './Locus'

class Test_Locus < Test::Unit::TestCase

  def compare_files(filename)
    # Result is compared with original file tested with Jason
    result = Locus.to_java("examples/#{filename}.esl")
    original = File.read("examples/#{filename}.java")
    # Ignore timestamp
    result.slice!(/Generated at .*/)
    original.slice!(/Generated at .*/)
    assert_equal(result, original)
  end

  def test_room
    compare_files('Room/RoomEnv')
  end

  def test_bakery_react
    compare_files('BakeryReact/Bakery')
  end

  def test_bakery_loop
    compare_files('BakeryLoop/Bakery')
  end
end