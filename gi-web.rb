# TODO: Parameterize gets to include api query params (user, type, state, label)
# TODO: Setup to deploy to Heroku
# TODO: Make issue numbers links to github
# TODO: Multiple get methods for Needs QA, Needs Code Review, WIP, etc.
# TODO: Fix time format on Label Applied column
# TODO: Improve performance

require 'sinatra'
require 'open-uri'
require 'json'
require 'haml'

GITHUB_USERNAME = ENV['GITHUB_USERNAME']
GITHUB_TOKEN = ENV['GITHUB_TOKEN']

get '/' do
  redirect '/needs_qa'
end

get '/needs_qa' do
  label = 'Needs QA'
  prs = get_sorted_github_pr_list_by_label(label)
  haml :index, :locals => {label: label, list: prs}
end

get '/needs_cr' do
  label = 'Needs Code Review'
  prs = get_sorted_github_pr_list_by_label(label)
  haml :index, :locals => {label: label, list: prs}
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

def get_label_event_data(items, label)
  items.each do |item|
    events = api_get("#{item['events_url']}?per_page=100")
    label_event = events.select { |e| e['event'] == 'labeled' && e['label']['name'] == label }.last
    item['label_event_data'] = label_event
  end
end

def get_sorted_github_pr_list_by_label(label)
  query = "state:open type:pr user:thinkthroughmath label:\"#{label}\""
  api_response = api_get("https://api.github.com/search/issues?q=#{query}")
  label = query.match(/label:\"(.*)\"/)[1]
  prs_with_label = get_label_event_data(api_response['items'], label)
  sort_items(prs_with_label)
end

def sort_items(items)
  items.sort_by { |i| i['label_event_data']['created_at'] }
end
