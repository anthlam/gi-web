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

  items = api_response['items']

  label = QUERY.match(/label:\"(.*)\"/)[1]

  items = get_label_event_data(items, label)

  items = sort_items(items)

  haml :index, :locals => {label: label, items: items}
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
