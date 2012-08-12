module Generate

	ENTITIES_DIR = 'data'

	# Dispatcher. Based on given attributes form config file invokes specific
	# generator or loader.
	def self.value args

		if args.include? 'null_density'
			if rand <= args['null_density']
				return nil
			end
		end

		case args['type']

			when 'string'

				min_length = (args.include?('min_length') && args['min_length'].is_a?(Integer)) ? args['min_length'] : 1
				max_length = (args.include?('max_length') && args['max_length'].is_a?(Integer)) ? args['max_length'] : 32
				Randomize.string min_length, max_length

			when 'number'

				min = (args.include?('min') && args['min'].is_a?(Integer)) ? args['min'] : 1
				max = (args.include?('max') && args['max'].is_a?(Integer)) ? args['max'] : 999
				Randomize.number min, max

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

				Randomize.date min, max

			when 'datetime'

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

				Randomize.time min, max

			when 'text'

				min_sentences = (args.include?('min_sentences') && args['min_sentences'].is_a?(Integer)) ? args['min_sentences'] : 1
				max_sentences = (args.include?('max_sentences') && args['max_sentences'].is_a?(Integer)) ? args['max_sentences'] : 20
				Randomize.text min_sentences, max_sentences

			when 'email'

				Randomize.email

			when 'phone_number'

				Randomize.phone_number

			when 'pesel'

				if args.include? 'fields_as_args'
					Randomize.send :pesel, args['args'][0], args['args'][1]
				else
					sex_letters = 'mf'
					date	= Randomize.date if date === nil
					sex		= sex_letters.sample if sex === nil

					Randomize.pesel date, sex
				end

			when 'postal_code'

				country_code = (args.include? 'country_code') ? args['country_code'] : nil

				Randomize.postal_code country_code

			when 'distributed'

				self.distributed_values args

			when 'entity'

				self.load_entity args

			when 'fixed'

				args['value']

			when 'code'

				eval args['code']

			else
				raise 'Unknown field type: ' + args['type']
		end
	end

	def self.distributed_values args
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
			suffix = self.value args['suffix']
			entities[rand(entities.length)] + suffix.to_s
		else
			entities[rand(entities.length)]
		end

	end
end

