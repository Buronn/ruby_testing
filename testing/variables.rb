require 'httparty'
require 'json'
require 'time'
require 'erb'
response = HTTParty.get('https://www.buda.com/api/v2/markets') # llamado a la api de buda para obtener los mercados en los que trabaja
ayer = Time.now.to_i - 86400 # timestamp actual menos 86400 (1 dia en seg)
puts Time.now.to_f * 1000 # timestamp actual en milisegundos 
class HTML_table # clase que contiene el nombre del mercado y su valor
  def initialize
    @info = []
  end

  def add_row(mercado, valor, cripto, tipo)
    @info.push([mercado, valor, cripto, tipo])
  end

  def get_binding
    binding
  end
end

if response.code == 200
  data = JSON.parse(response.body)
  html = HTML_table.new
  template = %(
  <html>
    <head><title>Tabla de datos</title></head>
    <body>
      <h1>Tabla de datos de máximas transacciones en las últimas 24 horas</h1>
      <table border="1">
        <tr>
          <th>Mercado</th>
          <th>Amount</th>
          <th>Price</th>
          <th>Direction</th>
        </tr>
        <% @info.each do |row| %>
          <tr>
            <td><%= row[0] %></td>
            <td><%= row[2] %></td>
            <td><%= row[1] %></td>
            <td><%= row[3] %></td>
          </tr>
        <% end %>
      </table>
    </body>
  </html>
).gsub(/^  /, '')
  rhtml = ERB.new(template)
  data['markets'].each do |child|
    response = HTTParty.get('https://www.buda.com/api/v2/markets/' + child['id'] + '/trades') # llamado a la api de buda para obtener las transacciones del mercado
    data2 = JSON.parse(response.body) if response.code == 200
    max_of_day = 0 # valor máximo
    max_of_day_cripto = 0
    tipo = '' # tipo de transacción
    data2['trades']['entries'].each do |child2|
      if child2[0].to_i > ayer # verifica si la transaccion se hizo hace 24hrs
        if child2[1].to_f * child2[2].to_f > max_of_day # multiplica el amount por price
          max_of_day = (child2[1].to_f * child2[2].to_f)
          max_of_day_cripto = child2[1].to_f
          tipo = child2[3]
        end
      else
        max_of_day = max_of_day
        max_of_day_cripto = max_of_day_cripto
      end
    end
    valor = max_of_day.to_s + ' ' + child['id'].split('-')[1]
    valor2 = max_of_day_cripto.to_s + ' ' + child['id'].split('-')[0]
    html.add_row(child['id'], valor, valor2, tipo)
  end
  rhtml.run(html.get_binding)
else # en el caso de no recibir code 200
  template = %(
  <html>
    <head><title>ERROR <%= response.code %></title></head>
    <body>
      <img src="https://http.cat/<%= response.code %>">
    </body>
  </html>
  ).gsub(/^  /, '')
  rhtml = ERB.new(template)
  rhtml.run(binding)
end
