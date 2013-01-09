
#Given a story type, returns the image name for it
def type_to_img(story_type)
  return "/#{story_type}.png"
end

# TODO check usages of this later.  More helpers like this?  Nuke this?
def friendly_title(story)
  "<h3>#{story.title}</h3>"
end

#Fetches current work - returns the body of the API response
def current(project, api_key)
	req = Net::HTTP::Get.new(
	      "/services/v3/projects/#{project}/iterations/current", 
	      {'X-TrackerToken'=>api_key}
	    )
	res = Net::HTTP.start(@pt_uri.host, @pt_uri.port) {|http|
	  http.request(req)
	}
	return res.body
end

def iterations(project, api_key, limit=1, skip=0)
	req = Net::HTTP::Get.new(
	      "/services/v3/projects/#{project}/iterations/current_backlog?limit=#{limit}&offset=#{skip}", 
	      {'X-TrackerToken'=>api_key}
	    )
	res = Net::HTTP.start(@pt_uri.host, @pt_uri.port) {|http|
	  http.request(req)
	}
	return res.body
end

def icebox(project, api_key, filter='')
	return stories(project, api_key, "state:unscheduled#{filter}")
end

def created_since(date, project, api_key, filter='')
  return stories(project, api_key, "created_since:#{date.strftime("%m/%d/%Y")}%20#{filter}")
end

def parse_stories_from_iterations(html)
	stories = Array.new
	story_iteration_iterator(Nokogiri::HTML(html)) { |story| stories << story }
	return stories
end

#Given an HTML doc, builds a story for each and yields each one
def story_iteration_iterator(doc)
	doc.xpath('//iteration').each do |i|
		due = Date.parse(i.xpath('finish')[0].content)
		i.xpath('//stories//story').each do |s|
			story = Story.new.from_xml(s)
			story.estimated_date = due
			yield story
		end
	end
end

#This wraps the story search
def stories(project, api_key, filter='')
	req = Net::HTTP::Get.new(
      "/services/v3/projects/#{project}/stories?filter=#{filter}", 
      {'X-TrackerToken'=>api_key}
    )
    res = Net::HTTP.start(@pt_uri.host, @pt_uri.port) {|http|
      http.request(req)
    }
    return res.body
end