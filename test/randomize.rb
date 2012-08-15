require_relative "../lib/Randomize"
require "test/unit"
require "date"

class TestRandomize < Test::Unit::TestCase

	def test_pesel
		pesel01 = Randomize.pesel(Date.new(1984,8,3), 'm')
		assert_equal(11, pesel01.length)
		assert_equal(1, pesel01[9].to_i % 2)
		assert_equal('840803', pesel01[0...6])
	end

	def test_time
		# Min and max set
		min		= '1990-01-01 12:00:00'
		max		= '1995-08-03 15:00:00'
		tmin	= DateTime.parse(min).to_time
		tmax	= DateTime.parse(max).to_time

		(0..9999).each {
			dt = Randomize.time tmin, tmax
			assert_instance_of Time, dt
			assert dt >= tmin, dt.to_s + ' is not greater than ' + tmin.to_s
			assert dt <= tmax, dt.to_s + ' is not lower than ' + tmax.to_s
		}
	end

	def test_date
		# Min and max set
		min		= '1984-01-01'
		max		= '2044-08-03'
		dmin	= Date.parse(min)
		dmax	= Date.parse(max)

		(0..9999).each {
			dt = Randomize.date dmin, dmax
			assert_instance_of Date, dt
			assert dt >= dmin, dt.to_s + ' is not greater than ' + dmin.to_s
			assert dt <= dmax, dt.to_s + ' is not lower than ' + dmax.to_s
		}
	end

	def test_words
		(0..9999).each {
			words = Randomize.words 1, 4
			assert_instance_of String, words
			assert_match /^[a-z][ a-z]*[a-z]$/, words
			assert_no_match /[0-9]+/, words
		}

		(0..9999).each {
			words = Randomize.words 1, 3, :first
			assert_instance_of String, words
			assert_match /^[A-Z].*[a-z]$/, words
		}

		(0..9999).each {
			words = Randomize.words 1, 3, false, true
			assert_instance_of String, words
			assert_match /^[a-z][-a-z]*[a-z]$/, words
			assert_no_match /\ /, words
		}
	end
end
