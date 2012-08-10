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
		# Min and max not set
		tmin	= Time.new(1950,1,1,0,0,0).to_time
		tmax	= Time.new(2009,12,31,23,59,59).to_time
		(0..9999).each {
			dt = DataGenerator.generate_datetime Hash.new
			assert_instance_of Time, dt
			assert dt >= tmin, dt.to_s + ' is not greater than ' + tmin.to_s
			assert dt <= tmax, dt.to_s + ' is not lower than ' + tmax.to_s
		}

		# Min and max set
		min		= '1990-01-01 12:00:00'
		max		= '1995-08-03 15:00:00'
		tmin	= DateTime.parse(min).to_time
		tmax	= DateTime.parse(max).to_time

		(0..9999).each {
			dt = DataGenerator.generate_datetime({ 'min' => min, 'max' => max })
			assert_instance_of Time, dt
			assert dt >= tmin, dt.to_s + ' is not greater than ' + tmin.to_s
			assert dt <= tmax, dt.to_s + ' is not lower than ' + tmax.to_s
		}
	end

	def test_generate_date
		# Min and max not set
		dmin	= Date.new(1950,1,1)
		dmax	= Date.new(2009,12,31)

		(0..9999).each {
			dt = DataGenerator.generate_date Hash.new
			assert_instance_of Date, dt
			assert dt >= dmin, dt.to_s + ' is not greater than ' + dmin.to_s
			assert dt <= dmax, dt.to_s + ' is not lower than ' + dmax.to_s
		}

		# Min and max set
		min		= '1984-01-01'
		max		= '2044-08-03'
		dmin	= Date.parse(min)
		dmax	= Date.parse(max)

		(0..9999).each {
			dt = DataGenerator.generate_date({ 'min' => min, 'max' => max })
			assert_instance_of Date, dt
			assert dt >= dmin, dt.to_s + ' is not greater than ' + dmin.to_s
			assert dt <= dmax, dt.to_s + ' is not lower than ' + dmax.to_s
		}
	end

end
