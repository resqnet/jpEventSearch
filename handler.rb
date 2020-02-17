require 'json'
require 'pp'
require 'json'
require 'net/http'
require 'open-uri'
require 'uri'
require "time"


def get_json(url)
  open(url).read
end

def search(i=1, ids=[])
  postData = {
    'token'   => '',
    'channel' => '',
    'text'    => ''
  }

  finished=true
  url = "https://connpass.com/api/v1/event/?order=3&count=100&start="

  json = get_json(url+i.to_s)
  result = JSON.parse(json)
  
  yesterday = (Date.today - 1).to_time + (60 * 60 * 17)
  
  pp url+i.to_s
  result['events'].each do |event| 
    next if event['limit'].nil?
    next if event['limit'] < 40
    return if Time.parse(event['updated_at']) <= yesterday
    return if ids.include?(event['event_id'])

    pp event['title']
    ids.push(event['event_id'])
    finished=false

    d = DateTime.parse(event['started_at'])
    w = %w(日 月 火 水 木 金 土)[d.wday] 

    postData['text'] = "開催日:#{d.strftime("%Y年%m月%d日 %H:%M:%S")}(#{w})\n#{event['title']}\n#{event['accepted']}/#{event['limit']}\n#{event['event_url']}"
    res = Net::HTTP.post_form(URI.parse('https://slack.com/api/chat.postMessage'), postData)
  end

  return if finished

  sleep (5)
  search(i+1, ids)
end

def hello(event:, context:)
  search()
  {
    statusCode: 200,
    body: {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      input: event
    }.to_json
  }
end

