
class Story
attr_reader :id, :title, :description, :url, :accepted_at, :requested_by, :owned_by, :created_at, :story_type, :current_state, :estimate, :updated_at
attr_accessor :estimated_date

# Builds a story given an XML node from pivotal tracker
def from_xml(node)
  @id = node.xpath('id')[0].content
  @title = node.xpath('name')[0].content
  @description = node.xpath('description')[0].content unless node.xpath('description')[0].nil?
  @url = node.xpath('url')[0].content
  accepted_at_node = node.xpath('accepted_at')[0]
  @accepted_at = accepted_at_node.nil? ? nil : DateTime.parse(accepted_at_node.content)
  @created_at = DateTime.parse(node.xpath('created_at')[0].content)
  @updated_at = DateTime.parse(node.xpath('updated_at')[0].content)
  @requested_by = node.xpath('requested_by')[0].content
  @current_state = node.xpath('current_state')[0].content
  owned_by_node = node.xpath('owned_by')[0]
  @owned_by = owned_by_node.nil? || owned_by_node.content.length == 0 ? 'no one' : owned_by_node.content
  @story_type = node.xpath('story_type')[0].content
  estimate_node = node.xpath('estimate')[0]
  @estimate = estimate_node.nil? ? 0 : estimate_node.content.to_i
  @estimate = 0 if @estimate < 0
  self
end

def self.count_stories_from_xml(xml_doc)
  return xml_doc.xpath('//stories')[0].attribute('count').value.to_i
end

#handy for turning labels into something more human readable
def self.human_format(str)
  return str if str.nil?
  str.gsub('z_', '').gsub(/[_-]/, ' ').capitalize
end

#This is the label for status that we show in the report
def friendly_state
  return '' if current_state == 'unstarted'
  return 'in progress' if current_state == 'started'
  current_state
end

# Given two stories (a and b) this is how you'd sort them
# if you wanted to sort by status
def self.status_sort(a,b)
  STATUS_PRIORITY[a.current_state] <=> STATUS_PRIORITY[b.current_state]
end

STATUS_PRIORITY = { 'rejected'=>1, 'delivered'=>2, 'finished'=>3, 'started'=>4 }

end