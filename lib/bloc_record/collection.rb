module BlocRecord
	class Collection < Array 
		
		def update_all(updates)
			ids = self.map(&id)
			self.any? ? self.first.class.update(ids, updates) : false
		end

		def destroy_all
			self.each do |item|
				self.forst.class.destroy(item.id)
			end
		end
	end
end