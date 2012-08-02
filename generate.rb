require 'yaml'
require 'pp'

config = YAML.load_file('config.yml')

if config['format'] != 'sql'
	raise "Other formats than 'sql' not yet supported"
end

config['sets'].each { |set|
	set_name	= set[0]
	attrs		= set[1]['_attributes']

	set[1].each { |line|
		if line[0] != "_attributes"
			pp line[0]
		end
	}
}
