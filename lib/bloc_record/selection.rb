require 'sqlite3'

module Selection 
	def find(*ids)
		if ids.kind_of? Integer  
			if ids.length == 1 && ids > 0
				find_one(ids.first)
			else
				rows = connection.execute <<-SQL
					SELECT #{columns.join ","} FROM #{table}
					WHERE id IN (#{ids.join(",")});
				SQL
				rows_to_array(rows)
			end
		else
			puts "Invalid id. Please enter a valid id."
		end
	end

	def find_one(id)
		if ids.kind_of? Interger && ids > 0
			row = connection.get_first_row <<-SQL 
				SELECT #{columns.join ","} FROM #{table}
				WHERE id = #{id};
			SQL
			init_object_from_row(row)
		else
			puts "Invalid id. Please enter a valid id."
		end
	end

	def find_by(attribute, value)
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			WHERE #{attribute} = {BlocRecord::Utility.sql_strings(value)};
		SQL
		init_object_from_row(row)
	end

	def find_each(options={})
		row = connection.execute <<-SQL
			SELECT * FROM #{table}
			ORDER BY #{table}
			LIMIT #{options[:batch_size]};
		SQL
		for row in rows_to_array(rows)
			yield(row)
		end
	end

	def find_in_batches(start, batch_size)
		rows = connection.execute <<-SQL
			SELECT #{colums.join ","} FROM #{table}
			LIMIT #{start}, #{batch_size};
		SQL
		yield(rows_to_array(rows))
	end

	def take(num=1)
		if num > 1
			rows = connection.execute <<-SQL
				SELECT #{columns.join ","} FROM #{table}
				ORDER BY random()
				LIMIT #{num};
			SQL
			rows_to_array(rows)
		else
			take_one
		end
	end

	def take_one
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			ORDER BY random()
			LIMIT 1;
		SQL
		init_object_from_row(row)
	end

	def first
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			ORDER BY id ASC LIMIT 1;
		SQL
		init_object_from_row(row)
	end

	def last
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			ORDER BY id DESC LIMIT 1;
		SQL
		init_object_from_row(row)
	end

	def all
		rows = connection.execute <<-SQL
			SELECT #{columns.join ","} FROM #{table};
		SQL
		rows_to_array(rows)
	end

	def where(*args)
		if args.count > 1
			expression = args.shift
			params = args
		else
			case args.first
			when String 
				expression = args.first
			when Hash 
				expression_hash = BlocRecord::Utility.convert_keys(args.first)
				expression = expression_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
			end
		end

		sql = <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			WHERE #{expression};
		SQL
		rows = connection.execute(sql, params)
		rows_to_array(rows)
	end

	def order(*args)
		case args.first
		when String
			if args.count > 1
				order = args.join(",")
			end
		when Symbol 
			order.args.first.to_s
		when Hash 
			order_hash = BlocRecord::Utility.convert_keys(args)
			order = order_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(",")
		end
		
		rows = connection.execute <<-SQL
			SELECT * FROM #{table}
			ORDER BY #{order};
		SQL
		rows_to_array(rows)
	end

	def join(*args)
		if args.count > 1 
			joins = args.map { |arg| "INNER JOIN #{arg} ON #{arg}.#{table}_id = #{table}.id"}.join(" ")
			rows = connection.execute <<-SQL
				SELECT * FROM #{table} #{joins};
			SQL
		else
			case args.first
			when String 
				rows = connection.execute <<-SQL
					SELECT * FROM #{table} #{BlocRecord::Utility.sql_strings(args.first)};
				SQL
			when Symbol
				rows = connection.execute <<-SQL
					SELECT * FROM #{table}
					INNER JOIN #{args.first} ON #{args.first}.#{table}_id = #{table}.id
				SQL
			when Hash 
				key = args.first.keys.first
				value = args.first[key]
				rows = connection.execute <<-SQL
					SELECT * FROM #{table}
					INNER JOIN #{key} ON #{key}.#{table}.id = #{table}.id
					INNER JOIN #{value} ON #{value}.#{key}_id = #{key}.id
				SQL
			end		
		end
		rows_to_array(rows)
	end

	private 

	def init_object_from_row(row)
		if row 
			data = Hash[columns.zip(row)]
			new(data)
		end
	end

	def rows_to_array(rows)
		collection = BlocRecord::Collection.new
		rows.each { |row| collection << new(Hash[columns.zip(row)]) }
		collection 
	end

	def method_missing(methId, *args)
		attribute = methId.to_s
		if columns.include?(attribute)
			find_by(attribute, *args)
		else
			puts "No #{attribute} found.  Please try again."
		end
		method_missing(methId, *args)
	end
end