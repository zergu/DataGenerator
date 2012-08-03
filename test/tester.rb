require_relative "../DataGenerator"
require "test/unit"
require "date"
 
class TestDataGenerator < Test::Unit::TestCase
 
  def test_calculate_pesel
	  pesel01 = DataGenerator.calculatePesel(Date.new(1984,8,3), 'm')
	  assert_equal(11, pesel01.length)
	  assert_equal(1, pesel01[9].to_i % 2)
	  assert_equal('840803', pesel01[0...6])
  end
 
end
