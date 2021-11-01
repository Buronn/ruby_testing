require 'httparty'
require 'json'
require 'time'
response = HTTParty.get('https://www.buda.com/api/v2/markets')
ayer = Time.now.to_i-86400
data = JSON.parse(response.body) if response.code == 200
data['markets'].each do |child|
  puts child['id']
  response = HTTParty.get('https://www.buda.com/api/v2/markets/'+child['id']+'/trades')#?timestamp='+ayer.to_s+'&limit=100')
  data2 = JSON.parse(response.body) if response.code == 200
  max_of_day = 0
  data2['trades']['entries'].each do |child2|
    
    if child2[0].to_i > ayer # compara si el timestamp es mayor al de ayer, o sea, si la transacción se hizo hace 24hrs
      child2[1].to_f > max_of_day ? max_of_day = child2[1].to_f : max_of_day = max_of_day # busca la mayor transacción del día
    end
  end
  puts 'max of the day ' + max_of_day.to_s + 'BTC' 
  puts "\n"
end
