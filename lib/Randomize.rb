module Randomize

	# Generates string from random chars
	# * min_length:: Minimum string length
	# * max_length:: Maximum string length
	def self.string min_length, max_length
		(min_length...max_length).map{65.+(rand(57)).chr}.join
	end

	# Generates random (quite pronounceable) word
	def self.word
		vovels		= 'aeiouy'
		consonants	= 'bcdfghjklmnpqrstvwz'
		word		= []
		switch		= true

		rand(4..14).times.collect do |x|
			if switch
				word << vovels[rand(vovels.length)]
			else
				word << consonants[rand(consonants.length)]
			end

			switch = !switch
		end

		word.join('')
	end

	# Generates random words with possible modifications
	# * min:: Minimum number of words
	# * max:: Maximum number of words
	# * sanitize_for_url:: Replace characters unwanted in url if true
	# * capitalize_words:: Possible values: :first, :all, false
	def self.words min, max, capitalize_words = false, sanitize_for_url = false
		words = []
		rand(min..max).times.collect do |x|
			words << self.word
		end

		words.map! { |x| x.capitalize } if capitalize_words === :all

		words = words.join(' ')

		words.capitalize! if capitalize_words === :first
		words.gsub!(/ /, '-') if sanitize_for_url

		words
	end

	# Generates random number (integer) from given range
	def self.number min, max
		rand min..max
	end

	# Generates random Time object within given range
	# * min:: Time object
	# * max:: Time object
	def self.time min, max
		Time.at(min + rand * (max.to_f - min.to_f))
	end

	# Generates random Date object within given range
	# * min:: Date object
	# * max:: Date object
	def self.date min, max
		self.time(min.to_time, max.to_time).to_date
	end

	# Generates random text (sentences) from "lorem ipsum" words.
	# * min_sentences:: Minimum number of sentences
	# * max_sentences:: Maximum number of sentences
	def self.text min_sentences, max_sentences
		lorem = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec leo tellus, ornare ac, molestie eu, suscipit non, urna. Sed in felis. Vivamus justo dui, tempus vel, blandit sed, placerat sit amet, nunc. Praesent rhoncus quam nec risus. Etiam eu nulla eu sapien ultrices hendrerit. Nulla et metus ac ipsum vulputate varius. Nullam nec mauris nec nulla ornare fermentum. In a libero. Aliquam erat volutpat. Ut ornare. Ut nec libero a metus posuere tincidunt. Sed sed arcu. Maecenas lobortis, massa sit amet convallis eleifend, neque erat commodo sapien, ut varius dolor quam vitae lorem. In tellus. Nam eu dolor. Aliquam erat volutpat. Nulla eu arcu. Mauris dignissim, neque egestas rhoncus feugiat, magna diam varius elit, ut hendrerit diam sapien vel velit. Donec lobortis. Aenean mattis turpis sed odio. Donec suscipit lectus quis felis. In hac habitasse platea dictumst. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nam interdum. Nulla facilisi. Donec facilisis. Phasellus tristique. Vestibulum pellentesque felis nec dui. Mauris dolor odio, mollis et, sollicitudin vitae, facilisis sed, enim. Duis velit. Nullam a augue. Aliquam erat volutpat. Aenean ut magna nec dui congue congue. Maecenas sagittis nisl ut neque. Nam facilisis urna sed purus luctus congue. Morbi interdum, ligula non ullamcorper faucibus, purus ipsum fermentum neque, in viverra nisi ante at turpis. Ut molestie gravida sapien. "
		sentences = lorem.split(". ").sort_by { rand }
		sentences[0..(min_sentences + rand(max_sentences))].join('. ')
	end

	# Generates random email addres
	def self.email
		tlds = ['com', 'org', 'net', 'biz', 'co.uk', 'pl', 'it', 'jp', 'tv', 'us', 'au' ]

		self.word + '@' + self.word + '.' + tlds.sample
	end

	# Generates random phone number (NNN-NNN-NNN)
	def self.phone_number
		rand(100_000_000..999_999_999).to_s.scan(/.../).join('-')
	end

	# Generates postal code
	# country_code:: ISO county code. Currently supports only 'PL', use nil to get most popular 5-digit code.
	def self.postal_code country_code
		pc = "%05d" % rand(99999)
		if country_code.upcase === 'PL'
			pc.scan(/(^..|...$)/).join('-')
		else
			pc
		end
	end

	# Calculates polish identification number - PESEL - using birth date and sex
	# * date:: Date of birth, Date object
	# * sex:: 'm' or 'f'
	def self.pesel date, sex

		weights			= [1, 3, 7, 9, 1, 3, 7, 9, 1, 3]
		male_digits		= '13579'
		female_digits	= '02468'

		full_year = date.year

		y = full_year % 100;
		m = date.month
		d = date.day

		if full_year >= 1800 && full_year <= 1899
			m += 80
		elsif full_year >= 2000 && full_year <= 2099
			m += 20
		elsif full_year >= 2100 && full_year <= 2199
			m += 40
		elsif full_year >= 2200 && full_year <= 2299
		 	m += 60
		end

		digits = [ (y/10).floor, y % 10, (m/10).floor, m % 10, (d/10).floor, d % 10 ]

		for i in digits.length..(weights.length - 1)
			digits[i] = rand(10)
		end

		if sex == 'm'
			digits[weights.length - 1] = male_digits[rand(5)].to_i
		elsif sex == 'f'
			digits[weights.length - 1] = female_digits[rand(5)].to_i
		else
			digits[weights.length - 1] = rand(10);
		end

		control_digit = 0

		for i in 0..(digits.length - 1)
			control_digit += weights[i] * digits[i]
		end

		control_digit = (10 - (control_digit % 10)) % 10

		pesel = ''
		for i in 0..(digits.length - 1)
			pesel += digits[i].to_s
		end

		pesel += control_digit.to_s

		pesel
	end
end

