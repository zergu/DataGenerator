require 'yaml'
require 'pp'
require_relative 'MetaDataObject'
require_relative 'DataGenerator'

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
				data[mdo.set_name] << { field_name => DataGenerator.generate_value(field_attrs) }
			}
		}
	end
}

pp data


