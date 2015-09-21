# TODO: Add tests
# TODO: Setup to deploy to Heroku
# TODO: Make issue numbers links to github
# TODO: Multiple get methods for Needs QA and Needs Code Review
# TODO: Fix time format on Label Applied column
# TODO: Improve performance

require 'sinatra'
require 'open-uri'
require 'json'
require 'haml'

GITHUB_USERNAME = ENV['GITHUB_USERNAME']
GITHUB_TOKEN = ENV['GITHUB_TOKEN']
QUERY = ENV['GI_QUERY']
BASE_URL = 'https://api.github.com'

get '/' do
  api_response = api_get("#{BASE_URL}/search/issues?q=#{QUERY}")

  issues = api_response['items']

  label = QUERY.match(/label:\"(.*)\"/)[1]

  issues = get_label_event_data(issues, label)

  issues = sort_items(issues)

  haml :index, :locals => {label: label, issues: issues}
end

def get_label_event_data(items, label)
  items.each do |item|
    events = api_get("#{item['events_url']}?per_page=100")
    label_event = events.select { |e| e['event'] == 'labeled' && e['label']['name'] == label }.last
    item['label_event_data'] = label_event
  end
end

def sort_items(items)
  items.sort_by { |i| i['label_event_data']['created_at'] }
end

def api_get(url)
  JSON.parse(
    open(url,
         'User-Agent' => GITHUB_USERNAME,
         'Authorization' => 'token ' + GITHUB_TOKEN,
         'Content-Type' => 'application/json',
         'Accept' => 'application/json')
    .read)
end
