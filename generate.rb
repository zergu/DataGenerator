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

# Read meta-data
i = 0
config['sets'].each { |set|
	mdo				= MetaDataObject.new
	mdo.set_name	= set[0]
	mdo.attrs		= set[1]['_attributes']

	set[1].each { |line|
		if line[0] != "_attributes"
			mdo.fields << { line[0] => line[1] }
		end
	}

	meta_data_objects[i] = mdo
	i += 1
}

# Build an array with rows representing desired data
meta_data_objects.each { |mdo|
	data[mdo.set_name] = []
	for i in 0..mdo.attrs["count"]
		row = []
		mdo.fields.each { |field|
			field.each_pair { |field_name, field_attrs|
				row.push DataGenerator.generate_value(field_attrs)
			}
		}
		data[mdo.set_name].push row
	end
}

# Write data to SQL format
sql = ''
meta_data_objects.each { |mdo|
	sql += 'INSERT INTO ' + mdo.set_name + '(' + mdo.field_names.join(', ') + ') VALUES ' + "\n"
	data[mdo.set_name].each { |row|
		sql += "\t("
		values = []
		row.each { |value|
			value = value.strftime('%Y-%m-%d') if value.instance_of? DateTime
			value = value.to_s if value.instance_of? Date
			value = value.to_s if value.instance_of? Fixnum
			values << "'" + value + "'"
		}
		sql += values.join(', ') + "),\n"
	}

	# Replace comma after last row with ending semicolon
	sql[-2] = ';'
	sql += "\n\n"
}

puts sql


