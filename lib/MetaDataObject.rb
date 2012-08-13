class MetaDataObject
	attr_accessor :set_name, :attrs, :fields, :index_map

	def initialize
		self.fields = []
		self.index_map = {}
	end

	def field_names
		field_names = []
		fields.each { |field|
			field_names << field.keys[0]
		}

		return field_names
	end

	def self.parse config
		mdos = []
		i = 0

		if config['sets']
			config['sets'].each { |set|
				mdo				= self.new
				mdo.set_name	= set[0]
				mdo.attrs		= set[1]['_attributes']

				j = 0
				set[1].each { |line|
					if line[0] != "_attributes"
						mdo.fields << { line[0] => line[1] }
						mdo.index_map[line[0]] = j
						j +=1
					end
				}

				mdos[i] = mdo
				i += 1
			}
		else
			raise 'Could not find any sets. Nothing to do. Is your config properly formatted?'
		end

		mdos
	end
end

