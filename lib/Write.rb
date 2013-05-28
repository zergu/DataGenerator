module Write

	def self.to_sql meta_data_objects, data, output_file
		sql = ''
		meta_data_objects.each { |mdo|
			sql += '------------------------------------------------------------' + "\n"
			sql += '--- ' + mdo.set_name + "\n"
			sql += '------------------------------------------------------------' + "\n\n"
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
	end

	def self.to_yml meta_data_objects, data, output_file
		yml	= ''

		meta_data_objects.each { |mdo|
			yml += '#------------------------------------------------------------' + "\n"
			yml += '#--- ' + mdo.set_name + "\n"
			yml += '#------------------------------------------------------------' + "\n\n"

			yml += mdo.set_name + ":\n"

			i = 1
			data[mdo.set_name].each { |row|
				yml += '  ' + mdo.set_name.downcase + "%05d" % i + ":\n"

				mdo.field_names.zip(row).each do |field, value|
					yml += "    "
					value = value.strftime('%Y-%m-%d %H:%M:%S') if value.instance_of? DateTime
					value = value.strftime('%Y-%m-%d %H:%M:%S') if value.instance_of? Time
					value = value.to_s if value.instance_of? Date

					if value === true
						value = 't'
					elsif value === false
						value = 'f'
					end

					if value === nil
						value = 'NULL'
					end

					if value.instance_of? Fixnum
						value = value.to_s
					end

					yml += field + ': ' + value + "\n"

				end

				i += 1
			}

			yml += "\n\n"

			File.open(output_file, 'w+') { |f| f.write(yml) }
		}
	end
end
