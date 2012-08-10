require_relative "../lib/DataGenerator"
require "test/unit"
require "date"

class TestDataGenerator < Test::Unit::TestCase

	def test_calculate_pesel
		pesel01 = DataGenerator.calculate_pesel(Date.new(1984,8,3), 'm')
		assert_equal(11, pesel01.length)
		assert_equal(1, pesel01[9].to_i % 2)
		assert_equal('840803', pesel01[0...6])
	end

	def test_generate_datetime
		min		= '1990-01-01 12:00:00'
		max		= '1995-08-03 15:00:00'
		tmin	= DateTime.parse(min).to_time
		tmax	= DateTime.parse(max).to_time

		(0..9999).each {
			dt = DataGenerator.generate_datetime({ 'min' => min, 'max' => max })
			assert_instance_of Time, dt
			assert dt > tmin, dt.to_s + ' is not greater than ' + tmin.to_s
			assert dt < tmax, dt.to_s + ' is not lower than ' + tmin.to_s
		}
	end

end
