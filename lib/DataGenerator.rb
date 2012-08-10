module DataGenerator

	ENTITIES_DIR = 'data'

	# Dispatcher. Based on given attributes form config file invokes specific
	# generator or loader.

	def self.generate_value(attrs)
		case attrs['type']
			when 'string'
				self.generate_string attrs
			when 'number'
				self.generate_number attrs
			when 'date'
				self.generate_date attrs
			when 'datetime'
				self.generate_datetime attrs
			when 'pesel'
				self.generate_pesel attrs
			when 'text'
				self.generate_text attrs
			when 'pl_postal_code'
				self.generate_pl_postal_code attrs
			when 'lorem'
				self.generate_lorem attrs
			when 'phone_number'
				self.generate_phone_number attrs
			when 'email'
				self.generate_email attrs
			when 'distributed'
				self.generate_distributed_values attrs
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
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end
		min_length = (args.include?('min_length') && args['min_length'].is_a?(Integer)) ? args['min_length'] : 32
		max_length = (args.include?('max_length') && args['max_length'].is_a?(Integer)) ? args['max_length'] : 32
		self.random_string(min_length, max_length)
	end

	def self.generate_number args
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end
		min = (args.include?('min') && args['min'].is_a?(Integer)) ? args['min'] : 1
		max = (args.include?('max') && args['max'].is_a?(Integer)) ? args['max'] : 999
		min + rand(1 + max - min)
	end

	def self.generate_date args
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end

		if args.include? 'min'
			begin
				min = Date.parse(args['min'])
			rescue
				min = Date.new(1950,1,1)
			end
		else
			min = Date.new(1950,1,1)
		end

		if args.include? 'max'
			begin
				max = Date.parse(args['max'])
			rescue
				max = Date.new(2009,12,31)
			end
		else
			max = Date.new(2009,12,31)
		end

		self.random_date min, max
	end

	def self.generate_datetime args
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end

		if args.include? 'min'
			begin
				min = DateTime.parse(args['min']).to_time
			rescue
				min = Time.new(1950,1,1,0,0,0)
			end
		else
			min = Time.new(1950,1,1,0,0,0)
		end

		if args.include? 'max'
			begin
				max = DateTime.parse(args['max']).to_time
			rescue
				max = Time.new(2009,12,31,23,59,59)
			end
		else
			max = Time.new(2009,12,31,23,59,59)
		end

		self.random_time min, max
	end

	def self.generate_text args
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end
		min = (args.include?('min') && args['min'].is_a?(Integer)) ? args['min'] : 1
		max = (args.include?('max') && args['max'].is_a?(Integer)) ? args['max'] : 999
		'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc leo augue, ultricies quis tristique vitae, fringilla non mi. Nullam vel mi leo, vitae lobortis neque. Nulla facilisi. Phasellus at dolor non metus feugiat cursus. In vel est sapien, nec sollicitudin eros. Nunc ornare, turpis venenatis viverra pretium, arcu sem aliquam est, non convallis metus velit eu tellus. Maecenas feugiat feugiat ullamcorper. Sed vel erat non arcu pharetra consectetur vitae at ante. Pellentesque non enim tortor. Nulla luctus pulvinar leo, varius placerat purus commodo in. Nulla sit amet magna eget tellus facilisis condimentum sit amet id tortor. Morbi viverra eros ut elit tristique convallis. Nunc quis lorem ut risus consectetur eleifend.'
	end

	def self.generate_lorem args
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end
		min_sentences = (args.include?('min_sentences') && args['min_sentences'].is_a?(Integer)) ? args['min_sentences'] : 1
		max_sentences = (args.include?('max_sentences') && args['max_sentences'].is_a?(Integer)) ? args['max_sentences'] : 20
		lorem = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec leo tellus, ornare ac, molestie eu, suscipit non, urna. Sed in felis. Vivamus justo dui, tempus vel, blandit sed, placerat sit amet, nunc. Praesent rhoncus quam nec risus. Etiam eu nulla eu sapien ultrices hendrerit. Nulla et metus ac ipsum vulputate varius. Nullam nec mauris nec nulla ornare fermentum. In a libero. Aliquam erat volutpat. Ut ornare. Ut nec libero a metus posuere tincidunt. Sed sed arcu. Maecenas lobortis, massa sit amet convallis eleifend, neque erat commodo sapien, ut varius dolor quam vitae lorem. In tellus. Nam eu dolor. Aliquam erat volutpat. Nulla eu arcu. Mauris dignissim, neque egestas rhoncus feugiat, magna diam varius elit, ut hendrerit diam sapien vel velit. Donec lobortis. Aenean mattis turpis sed odio. Donec suscipit lectus quis felis. In hac habitasse platea dictumst. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nam interdum. Nulla facilisi. Donec facilisis. Phasellus tristique. Vestibulum pellentesque felis nec dui. Mauris dolor odio, mollis et, sollicitudin vitae, facilisis sed, enim. Duis velit. Nullam a augue. Aliquam erat volutpat. Aenean ut magna nec dui congue congue. Maecenas sagittis nisl ut neque. Nam facilisis urna sed purus luctus congue. Morbi interdum, ligula non ullamcorper faucibus, purus ipsum fermentum neque, in viverra nisi ante at turpis. Ut molestie gravida sapien. "
		sentences = lorem.split(". ").sort_by { rand }
		sentences[0..(min_sentences + rand(max_sentences))].join('. ')
	end

	def self.generate_phone_number args
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end

		rand(100_000_000...999_999_999).to_s.scan(/.../).join('-')
	end

	def self.generate_email args
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end

		tlds = ['com', 'org', 'net', 'biz', 'co.uk', 'pl', 'it', 'jp', 'tv', 'us', 'au' ]
		letters = ('a'..'z').to_a

		name	= []
		domain	= []

		rand(3..10).times { name << letters.sample }
		rand(3..10).times { domain << letters.sample }

		name.join + '@' + domain.join + '.' + tlds.sample
	end

	def self.generate_pesel args
		if args.include? 'fields_as_args'
			self.send :random_pesel, *args['args']
		else
			self.random_pesel
		end
	end

	def self.generate_distributed_values args
		if not args.include? 'values'
			raise "Data type 'distributed' requires 'values' attribute"
		end

		ratio_sum	= 0
		i			= 0
		ratio_steps	= []

		args['values'].each { |set|
			if set[1] > 1
				raise "Ratio can't be higher than 1 (for value: " + set[0] + ")"
			else
				ratio_sum += set[1]
				if i === 0
					ratio_steps[i] = [set[0], set[1]]
				else
					ratio_steps[i] = [set[0], set[1] + ratio_steps[i - 1][1]]
				end

				i += 1
			end
		}

		if ratio_sum > 1
			raise "Ratios do not sum up 1. Please fix this."
		end

		rvalue = rand
		ratio_steps.each { |set|
			if rvalue < set[1]
				return set[0]
			end
		}
	end

	def self.generate_pl_postal_code args
		chars = '0123456789'
		chars[rand(chars.size)] + chars[rand(chars.size)] + '-' + chars[rand(chars.size)] + chars[rand(chars.size)] + chars[rand(chars.size)]
	end

	# Loads a single value from specified data source (file)
	def self.load_entity args

		if not args.include? 'from'
			raise 'Entity type need a "from" attribute'
		end

		file_path = self::ENTITIES_DIR + File::SEPARATOR + args['from']

		if File.exists? file_path
			entities = IO.read(file_path).split("\n")
		else
			raise 'Could not find entities file: ' + file_path
		end

		if args.include? 'suffix'
			suffix = self.generate_value args['suffix']
			entities[rand(entities.length)] + suffix.to_s
		else
			entities[rand(entities.length)]
		end

	end

	def self.random_string min_length, max_length
		(min_length...max_length).map{65.+(rand(57)).chr}.join
	end

	# Generates random Time object within given range
	# * min:: Time object
	# * max:: Time object
	def self.random_time min, max
		Time.at(min + rand * (max.to_f - min.to_f))
	end

	# Generates random Date object within given range
	# * min:: Date object
	# * max:: Date object
	def self.random_date min, max
		self.random_time(min.to_time, max.to_time).to_date
	end

	def self.random_pesel date = nil, sex = nil
		sex_letters = 'mf'
		date	= self.random_date if date === nil
		sex		= sex_letters[rand(2)] if sex === nil
		self.calculate_pesel date, sex
	end

	# Calculates polish identification number - PESEL - using birth date and sex
	# * date:: Date of birth, Date object
	# * sex:: 'm' or 'f'
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

		r = ''
		for i in 0..(digits.length - 1)
			r += digits[i].to_s
		end

		r += control_digit.to_s

		return r
	end
end

