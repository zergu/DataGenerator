module Generate

	ENTITIES_DIR = 'data'
	@@serials = {}

	# Dispatcher. Based on given attributes form config file invokes specific
	# generator or loader.
	def self.value args

		# Type check
		if not args.include? 'type'
			raise 'Fatal. Found field without specified type: ' + args.inspect
		end

		# Global parameter: null density
		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end

		# Dispatcher
		case args['type']

		when 'string'

			min_length = (args.include?('min_length') && args['min_length'].is_a?(Integer)) ? args['min_length'] : 1
			max_length = (args.include?('max_length') && args['max_length'].is_a?(Integer)) ? args['max_length'] : 32
			v = Randomize.string min_length, max_length

		when 'word'

			v = Randomize.word

		when 'number'

			min = (args.include?('min') && args['min'].is_a?(Integer)) ? args['min'] : 1
			max = (args.include?('max') && args['max'].is_a?(Integer)) ? args['max'] : 999
			v = Randomize.number min, max

		when 'serial'

			start		= (args.include?('start') && args['start'].is_a?(Integer)) ? args['start'] : 1
			seq_name	= args['set_name'] + '_' + args['field_name'] + '_seq'

			if self.serials.include? seq_name
				self.serials[seq_name] += 1
			else
				self.serials[seq_name] = start
			end

			v = self.serials[seq_name]

		when 'date'

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

			v = Randomize.date min, max

		when 'datetime'

			if args.include? 'diff_from_value'
				v = DateTime.parse(args['diff_from_value']).to_time.getutc + args['diff_by_seconds'].to_i
			else
				min = DateTime.parse(args['min'] || raise).to_time rescue Time.new(1950, 1, 1, 0, 0, 0)
				max = DateTime.parse(args['max'] || raise).to_time rescue Time.new(2009, 12, 31, 23, 59, 59)

				v = Randomize.time min, max
			end

		when 'date_and_time'

			min_date = DateTime.parse(args['min_date'] || raise).to_time rescue Time.new(1950, 1, 1, 0, 0, 0)
			max_date = DateTime.parse(args['max_date'] || raise).to_time rescue Time.new(2009, 12, 31, 23, 59, 59)

			time = Randomize.time_of_day args['min_time'], args['max_time'], args['minute_quantifier']
			date = Randomize.date min_date, max_date

			v = date.to_s + ' ' + time.to_s + ':00'

		when 'text'

			min_sentences = (args.include?('min_sentences') && args['min_sentences'].is_a?(Integer)) ? args['min_sentences'] : 1
			max_sentences = (args.include?('max_sentences') && args['max_sentences'].is_a?(Integer)) ? args['max_sentences'] : 20
			v = Randomize.text min_sentences, max_sentences

		when 'duplicate'

			if not args.include? 'duplicate_value'
				raise 'Value from "duplicate" field could not be taken. Pleas recheck your config'
			end

			v = args['duplicate_value']

		when 'email'

			v = Randomize.email

		when 'phone_number'

			v = Randomize.phone_number

		when 'pesel'

			if args.include? 'fields_as_args'
				v = Randomize.send :pesel, args['args'][0], args['args'][1]
			else
				sex_letters = 'mf'
				date	= Randomize.date if date === nil
				sex		= sex_letters.sample if sex === nil

				v = Randomize.pesel date, sex
			end

		when 'postal_code'

			country_code = (args.include? 'country_code') ? args['country_code'] : nil

			v = Randomize.postal_code country_code

		when 'distributed'

			if not args.include? 'values'
				raise "Data type 'distributed' requires 'values' attribute"
			end

			v = self.distributed_values args['values']

		when 'entity'

			if not args.include? 'from'
				raise 'Entity type need a "from" attribute'
			end

			if args['from'] === nil or args['from' === '']
				raise 'Entity "from" attribute must not be empty'
			end

			file_path = self::ENTITIES_DIR + File::SEPARATOR + args['from']

			if not File.exists? file_path
				raise 'Could not find entities file: ' + file_path
			end

			v = self.load_entity file_path

		when 'fixed'

			v = args['value']

		when 'code'

			v = eval args['code']

		else
			raise 'Unknown field type: ' + args['type']
		end

		# Global parameter for strings: prefix
		if args.include? 'prefix' and v.respond_to? :to_s
			prefix = self.value args['prefix']
			v = prefix.to_s + v.to_s
		end

		# Global parameter for strings: suffix
		if args.include? 'suffix' and v.respond_to? :to_s
			suffix = self.value args['suffix']
			v = v.to_s + suffix.to_s
		end

		return v
	end

	def self.distributed_values values

		ratio_sum	= 0
		i			= 0
		ratio_steps	= []

		values.each { |set|
			if not (0..1).member? set[1]
				raise "Ratio must be from 0-1 range (for value: " + set[0].to_s + ")."
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

	# Loads a single value from specified data source (file)
	def self.load_entity file_path

		entities = IO.read(file_path).split("\n")
		entities[rand(entities.length)]

	end

	def self.serials
		@@serials
	end

	def self.serials= v
		@@serials = v
	end
end

