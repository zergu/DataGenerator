#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require_relative 'lib/MetaDataObject'
require_relative 'lib/DataGenerator'

###
### Parse command line options
###

options = {}

optparse = OptionParser.new do |opts|
	# Set a banner, displayed at the top
	# of the help screen.
	opts.banner = "Usage: ruby generate.rb [options]"

	# Define the options, and what they do
	options[:output_file] = nil
	opts.on( '-f', '--file FILE', 'Use different output file than ./generated-data.sql' ) do |file|
		options[:output_file] = file
	end

	options[:config_file] = nil
	opts.on( '-c', '--config FILE', 'Use different config file than ./config.yml' ) do |file|
		options[:config_file] = file
	end

	# This displays the help screen, all programs are
	# assumed to have this option.
	opts.on( '-h', '--help', 'Display this screen' ) do
		puts opts
		exit
	end
end.parse!

###
### Initial setup and load config file
###

# Read config file
config = YAML.load_file(options[:config_file] || 'config.yml')

# Translate config meta-data objects
meta_data_objects = MetaDataObject.parse config

# Setup output file
output_file = options[:output_file] || 'generated-data.sql'

# Check output file format
if config['format'] != 'sql'
	raise "Other formats than 'sql' not yet supported"
end

# Initialize data container
data = {}

###
### Fill data container with rows representing desired generated/randomized data
###

meta_data_objects.each { |mdo|
	data[mdo.set_name] = []

	for i in 0..mdo.attrs['count']
		row = []
		mdo.fields.each { |field|
			field.each_pair { |field_name, field_attrs|

				# If 'fields_as_args' are set in configuration file try to use already
				# generated values to calculate current field (like using 'city' to find
				# a 'country').
				if field_attrs.include? 'fields_as_args'
					field_attrs['args'] = []
					field_attrs['fields_as_args'].each { |a|
						field_attrs['args'] << row[mdo.index_map[a]] if mdo.index_map.key? a
					}
				end

				row.push DataGenerator.generate_value(field_attrs)
			}
		}
		data[mdo.set_name].push row
	end
}

###
### Write data to file in (Postgre)SQL format
###

sql = ''
meta_data_objects.each { |mdo|
	sql += 'INSERT INTO ' + mdo.set_name + '(' + mdo.field_names.join(', ') + ') VALUES ' + "\n"
	data[mdo.set_name].each { |row|
		sql += "\t("
		values = []
		row.each { |value|
			value = value.strftime('%Y-%m-%d %H:%M:%S') if value.instance_of? DateTime
			value = value.strftime('%Y-%m-%d %H:%M:%S') if value.instance_of? Time
			value = value.to_s if value.instance_of? Date

			if value === true
				value = 't'
			elsif value === false
				value = 'f'
			end

			if value.instance_of? Fixnum
				values << value
			elsif value === nil
				values << 'NULL'
			else
				begin
					# FIXME problem with \ as a last character
					values << "'" + value + "'"
				rescue TypeError
					puts "Can't convert value to string: " + value.inspect
				end
			end
		}
		sql += values.join(', ') + "),\n"
	}

	# Replace comma after last row with ending semicolon
	sql[-2] = ';'
	sql += "\n\n"

	File.open(output_file, 'w+') { |f| f.write(sql) }
}

