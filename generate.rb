require 'yaml'
require 'pp'

###########################

class MetaDataObject
	attr_accessor :set_name, :attrs, :fields

	def initialize
		self.fields = []
	end
end

###########################

class DataGenerator
	def self.generateValue(attrs)
		case attrs['type']
		when 'string'
			self.generateString attrs
		else
			return nil
		end
	end

	def self.generateString(*args)
		args = args[0]
		max_length = (args.include?('max_length') && args['max_length'].is_a?(Integer)) ? args['max_length'] : 32
		pp max_length
	end
end

###########################

config = YAML.load_file('config.yml')

if config['format'] != 'sql'
	raise "Other formats than 'sql' not yet supported"
end

meta_data_objects = []
data = {}

config['sets'].each { |set|
	mdo				= MetaDataObject.new
	mdo.set_name	= set[0]
	mdo.attrs		= set[1]['_attributes']

	set[1].each { |line|
		if line[0] != "_attributes"
			mdo.fields << { line[0] => line[1] }
		end
	}

	meta_data_objects << mdo
}

meta_data_objects.each { |mdo|
	data[mdo.set_name] = []
	for i in 0..mdo.attrs["count"]
		mdo.fields.each { |field|
			field.each_pair { |field_name, field_attrs|
				data[mdo.set_name] << { field_name => DataGenerator.generateValue(field_attrs) }
			}
		}
	end
}

#pp data


