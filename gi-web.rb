require 'sinatra'
require 'open-uri'
require 'json'
require 'haml'

GITHUB_USERNAME = ENV['GITHUB_USERNAME']
GITHUB_TOKEN = ENV['GITHUB_TOKEN']
QUERY = ENV['GI_QUERY']

get '/' do
  api_response = open('https://api.github.com/search/issues?q=state:open type:pr user:thinkthroughmath label:"Needs QA"',
       'User-Agent' => GITHUB_USERNAME,
       'Authorization' => 'token ' + GITHUB_TOKEN,
       'Content-Type' => 'application/json',
       'Accept' => 'application/json').read

  results = JSON.parse(api_response)

  @items = results['items']

  haml :index
end
