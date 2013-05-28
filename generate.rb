#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require_relative 'lib/MetaDataObject'
require_relative 'lib/Generate'
require_relative 'lib/Randomize'
require_relative 'lib/Write'

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
	opts.on( '-f', '--file FILE', 'Use different output file than ./generated-data.$ext' ) do |file|
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
output_file = options[:output_file] || 'generated-data.' + config['format']

# Check output file format
if not ['sql', 'yml'].include? config['format']
	raise "Other formats than 'sql' not yet supported"
end

# Initialize data container
data = {}

# Initialize serial (sequence) container
$serials = {}

###
### Fill data container with rows representing desired generated/randomized data
###

meta_data_objects.each { |mdo|
	data[mdo.set_name] = []

	for i in 1..mdo.attrs['count']
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

				# If field is marked as diff_from, use other's field value to calculate diff
				if field_attrs.include? 'diff_from'
					field_attrs['diff_from_value'] = row[mdo.index_map[field_attrs['diff_from']]] if mdo.index_map.key? field_attrs['diff_from']
				end

				# Special handling of 'duplicate' type cause it needs to access other field value
				if field_attrs['type'] === 'duplicate'
					field_attrs['duplicate_value'] = row[mdo.index_map[field_attrs['field']]] if mdo.index_map.key? field_attrs['field']
				end

				# Special handling of 'relational' type type cause it needs to access other field value
				if field_attrs['type'] === 'relational'
					rel_name = field_attrs['relation_table']+'.'+field_attrs['relation_field']

					if not defined? $serials[rel_name] or $serials[rel_name].nil?
						raise 'Unknown table defined relation: ' + rel_name
					end

					if field_attrs['relation_type'] === '1-1'
						copy = $serials[rel_name].shift
						field_attrs['relational_value'] = copy
						$serials[rel_name].push copy
					elsif field_attrs['relation_type'] === 'random'
						field_attrs['relational_value'] = $serials[rel_name].sample
					else
						raise 'Unkown relation type for ' + mdo.set_name + '.' + field_name
					end
				end

				field_attrs['set_name']		= mdo.set_name
				field_attrs['field_name']	= field_name

				value = Generate.value field_attrs

				# Remember all serial values for further use
				if field_attrs['type'] === 'serial'
					if ($serials[mdo.set_name+'.'+field_name]) === nil
						$serials[mdo.set_name+'.'+field_name] = []
					end
					$serials[mdo.set_name+'.'+field_name].push value
				end

				row.push value
			}


		}
		data[mdo.set_name].push row
	end
}

###
### Write data to file in (Postgre)SQL format
###

case config['format']
	when 'yml'
		Write.to_yml meta_data_objects, data, output_file
	else
		Write.to_sql meta_data_objects, data, output_file
end

