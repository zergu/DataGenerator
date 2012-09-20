require_relative "../lib/Randomize"
require "test/unit"
require "date"

class TestTimeOfDay < Test::Unit::TestCase
	def test
		(0..9999).each {
			tod = Randomize.time_of_day
			assert_match /^((0[0-9])|(1[0-9])|2[0-3]):([0-5][0-9])$/, tod
		}

		(0..9999).each {
			tod = Randomize.time_of_day 2
			assert_match /^((0[0-9])|(1[0-9])|2[0-3]):([0-5][02468])$/, tod
		}

		(0..9999).each {
			tod = Randomize.time_of_day 15
			assert_match /^((0[0-9])|(1[0-9])|2[0-3]):(00)|(15)|(30)|(45)$/, tod, tod + ' is not quantified by 15'
		}

		(0..9999).each {
			tod = Randomize.time_of_day 0
			assert_match /^((0[0-9])|(1[0-9])|2[0-3]):00$/, tod, tod + ' is not rounded hour'
		}
	end
end

