class DataGenerator
	def self.generateValue(attrs)
		case attrs['type']
			when 'string'
				self.generateString attrs
			when 'date'
				self.generateDate attrs
			when 'pesel'
				self.generatePesel attrs
			else
				return nil
		end
	end

	def self.generateString args
		min_length = (args.include?('min_length') && args['min_length'].is_a?(Integer)) ? args['min_length'] : 32
		max_length = (args.include?('max_length') && args['max_length'].is_a?(Integer)) ? args['max_length'] : 32
		self.randomString(min_length, max_length)
	end

	def self.generateDate args
		# TODO handle date range
		#min = (args.include?('min') && args['min'].is_a?(Integer)) ? args['min'] : 32
		#max = (args.include?('max') && args['max'].is_a?(Integer)) ? args['max'] : 32
		self.randomDate
	end

	def self.generatePesel args
		self.randomPesel
	end

	def self.randomString min_length, max_length
		(min_length...max_length).map{65.+(rand(57)).chr}.join
	end

	def self.randomTime from = 0.0, to = Time.now
		Time.at(from + rand * (to.to_f - from.to_f))
	end

	def self.randomDate from = 0.0, to = Time.now
		Date.parse(self.randomTime.to_s)
	end

	def self.randomPesel
		sex_letters = 'mf'
		self.calculatePesel self.randomDate, sex_letters[rand(2)]
	end

	# Calculates polish identification number - PESEL - using birth date and sex
	def self.calculatePesel date, sex
		weights			= [1, 3, 7, 9, 1, 3, 7, 9, 1, 3]
		male_digits		= '13579'
		female_digits	= '02468'

	    full_year = date.year
    
		y = full_year % 100;
		m = date.month
		d = date.day
    
		if full_year >= 1800 && full_year <= 1899
		    m += 80
		elsif full_year >= 2000 && full_year <= 2099
		    m += 20
		elsif full_year >= 2100 && full_year <= 2199
		    m += 40
		elsif full_year >= 2200 && full_year <= 2299
		    m += 60
		end
		
		digits = [ (y/10).floor, y % 10, (m/10).floor, m % 10, (d/10).floor, d % 10 ]

		for i in digits.length..(weights.length - 1)
		    digits[i] = rand(10)
		end

		if sex == 'm'
		    digits[weights.length - 1] = male_digits[rand(5)].to_i
		elsif sex == 'f'
		    digits[weights.length - 1] = female_digits[rand(5)].to_i
		else
		    digits[weights.length - 1] = rand(10);
		end
		    
		control_digit = 0

		for i in 0..(digits.length - 1)
		    control_digit += weights[i] * digits[i]
		end

		control_digit = (10 - (control_digit % 10)) % 10
		            
		r = '';
		for i in 0..(digits.length - 1)
		    r += digits[i].to_s
		end

		r += control_digit.to_s    
	
		return r
	end
end

