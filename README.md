DataGenerator
=============

Generates ready for insertion SQL file with various (calculated or randomized) data.

How to use it?
--------------

1. Download source code.
2. Open `config.yml` and adjust it to your own needs.
3. Run `ruby generate.rb`.
4. Insert generated SQL file into your database. :-)

Known issues
------------

As of early August 2012 project is in very early stage so expect all kind of problems. Sorry.

Example config file (YAML)
--------------------------

	format: sql
	sets:
	    patients:
	        _attributes: { count: 200 }
	        application_id: { type: fixed, value: 3 }
	        name1: { type: entity, from: first_names_pl }
	        lastname1: { type: entity, from: last_names_pl }
	        birthday_at: { type: date, min: 1900-01-01, max: 2006-12-31 }
	        pesel: { type: pesel, fields_as_args: [birthday_at] }
	        country: { type: entity, from: countries_pl }
	        gender_id: { type: number, min: 1, max: 2 }
	        active: { type: fixed, value: true }
	        created_at: { type: code, code: 'DateTime.now()' }
	    visits:
	        _attributes: { count: 350 }
	        patient_id: { type: number, min: 2, max: 5 }
	        description: { type: lorem, min_sentences: 2, max_sentences: 5 }

Supported field types: generic
------------------------------

*	**fixed**

	Required: **value**  
	Simply set this field to *value*.

*	**number**

	Optional: **min** (default: 1)  
	Optional: **max** (default: 999)  
	Random number from *min* — *max* range.

*	**date**

	Random date.

*	**entity**

	Required: **from**  
	Loads a random value from dictionary specified in *from* attribute. Check dictionaries
	in *data/* dir.

*	**lorem**

	Optional: min_sentences (default: 1)  
	Optional: max_sentences (default: 20)  
	Generates pseudo-text with random number of sentences from famous *Lorem Ipsum*.

*	**distributed**

	Required: values (Array of Arrays)  
	Randomizes fixed values using their weights. Example values can look like this:  
	`[ ['ruby', 0.2], ['php', 0.4], ['python', 0.25], ['c++', 0.14], ['java', 0.01] ]`
	Meaning that you have 20% chance to get 'ruby' value, 40% for 'php' and so on. This
	does not guarantee that exaclty 20% of values will be 'ruby' because they are
	randoized independantly. Keep in mind that weights have to sum up to 1.

*	**code**

	Required: **code**  
	Value is generated with specified Ruby code.

Supported field types: specific
-------------------------------

*	**pesel**

	Optional: Array **fields_as_args**  
	Method arguments: date = nil, sex = nil  
	Generates Polish person's identification number using specific algorithm. Can be random
	but should depend on someone's birth date and sex cause they're required for proper calculations.
	Attribute *fields_as_args* allows using values generated for other fields but they should be placed
	before current field.

*	**phone_number**

	Optional: **null_density** (0..1)  
	Generates random phone number matching pattern XXX-XXX-XXX, where X = 0..9.

*	**email**

	Optional: **null_density** (0..1)
	Generates random email matching pattern X@X.TLD, where X = where X is random string (3…10 chars)
	and TLD is one of few top-level domains.

*	**pl_postal_code**

	Random polish postal code matching XX-XXX, where X = 0..9.

Imagining the future
--------------------

* Writing also to CSV.
* Support for auto-increment fields and SQL COPY format.
* More specific generators.
* Much more dictionaries.
* Constant code refactorization (to improve my Ruby skills).
* Code unit tested.
* All issues closed.

Found DataGenerator useful? Please consider donation.
-----------------------------------------------------

<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
">
<input type="image" src="https://www.paypalobjects.com/en_US/PL/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/pl_PL/i/scr/pixel.gif" width="1" height="1">
</form>
