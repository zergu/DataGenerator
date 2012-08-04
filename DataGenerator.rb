class DataGenerator

	ENTITIES_DIR = 'data'

	# Dispatcher. Based on given attributes form config file invokes specific
	# generator or loader.
	#
	# TODO Read attrs here so generators will be more reusable?
	def self.generate_value(attrs)
		case attrs['type']
			when 'string'
				self.generate_string attrs
			when 'number'
				self.generate_number attrs
			when 'date'
				self.generate_date attrs
			when 'pesel'
				self.generate_pesel attrs
			when 'text'
				self.generate_text attrs
			when 'entity'
				self.load_entity attrs
			when 'fixed'
				attrs['value']
			when 'code'
				eval attrs['code']
			else
				return nil
		end
	end

	def self.generate_string args
		min_length = (args.include?('min_length') && args['min_length'].is_a?(Integer)) ? args['min_length'] : 32
		max_length = (args.include?('max_length') && args['max_length'].is_a?(Integer)) ? args['max_length'] : 32
		self.random_string(min_length, max_length)
	end

	def self.generate_number args
		min = (args.include?('min') && args['min'].is_a?(Integer)) ? args['min'] : 1
		max = (args.include?('max') && args['max'].is_a?(Integer)) ? args['max'] : 999
		min + rand(1 + max - min)
	end

	def self.generate_date args
		# TODO handle date range
		#min = (args.include?('min') && args['min'].is_a?(Integer)) ? args['min'] : 32
		#max = (args.include?('max') && args['max'].is_a?(Integer)) ? args['max'] : 32
		self.random_date
	end

	def self.generate_text args
		'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc leo augue, ultricies quis tristique vitae, fringilla non mi. Nullam vel mi leo, vitae lobortis neque. Nulla facilisi. Phasellus at dolor non metus feugiat cursus. In vel est sapien, nec sollicitudin eros. Nunc ornare, turpis venenatis viverra pretium, arcu sem aliquam est, non convallis metus velit eu tellus. Maecenas feugiat feugiat ullamcorper. Sed vel erat non arcu pharetra consectetur vitae at ante. Pellentesque non enim tortor. Nulla luctus pulvinar leo, varius placerat purus commodo in. Nulla sit amet magna eget tellus facilisis condimentum sit amet id tortor. Morbi viverra eros ut elit tristique convallis. Nunc quis lorem ut risus consectetur eleifend.'
	end

	def self.generate_pesel args
		self.random_pesel
	end

	# Loads a single value from specified data source (file)
	def self.load_entity args
		file_path = self::ENTITIES_DIR + File::SEPARATOR + args['from']

		if File.exists? file_path
			entities = IO.read(file_path).split
		else
			raise 'Could not find entities file: ' + file_path
		end

		entities[rand(entities.length)]
	end

	def self.random_string min_length, max_length
		(min_length...max_length).map{65.+(rand(57)).chr}.join
	end

	def self.random_time from = 0.0, to = Time.now
		Time.at(from + rand * (to.to_f - from.to_f))
	end

	def self.random_date from = 0.0, to = Time.now
		Date.parse(self.random_time.to_s)
	end

	def self.random_pesel
		sex_letters = 'mf'
		self.calculate_pesel self.random_date, sex_letters[rand(2)]
	end

	# Calculates polish identification number - PESEL - using birth date and sex
	def self.calculate_pesel date, sex
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

