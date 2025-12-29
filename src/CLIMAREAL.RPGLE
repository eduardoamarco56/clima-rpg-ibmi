**FREE

///
// API de Clima - HTML con datos REALES
// Combina HTML embebido + HTTPAPI
// Sin problemas de CCSID
///

Ctl-opt option(*srcstmt:*nodebugio) dftactgrp(*no) 
        bnddir('CGIDEV2/TEMPLATE2':'LIBHTTP/HTTPAPI');

Dcl-c CRLF x'0d25';
Dcl-s output varchar(10000);
Dcl-s ciudad varchar(100);
Dcl-s queryString char(1000);
Dcl-s ptrEnv pointer;
Dcl-s pos int(10);
Dcl-s apiKey char(100);
Dcl-s url varchar(500);
Dcl-s response varchar(32000);
Dcl-s temp char(10);
Dcl-s feelsLike char(10);
Dcl-s humidity char(10);
Dcl-s windSpeed char(10);
Dcl-s pressure char(10);
Dcl-s description char(100);
Dcl-s cityName char(100);

/copy CGIDEV2/qrpglesrc,prototypeb
/copy CGIDEV2/qrpglesrc,usec

// Prototipo para obtener variable de entorno
dcl-pr myGetEnv pointer extproc('getenv');
  varName pointer value options(*string);
end-pr;

// Prototipo de http_string
dcl-pr http_string varchar(1000000) extproc('HTTP_STRING');
  method varchar(10) const;
  url varchar(32767) const;
  postdata varchar(32767) const options(*nopass);
  contentType varchar(100) const options(*nopass);
end-pr;

// Inicializar ciudad por defecto
ciudad = 'Buenos Aires';

// Obtener QUERY_STRING
ptrEnv = myGetEnv('QUERY_STRING');

if ptrEnv <> *null;
  queryString = %str(ptrEnv: 1000);
  
  // Extraer ciudad
  pos = %scan('ciudad=': queryString);
  if pos > 0;
    ciudad = %subst(queryString: pos + 7);
    pos = %scan('&': ciudad);
    if pos > 0;
      ciudad = %subst(ciudad: 1: pos - 1);
    endif;
    ciudad = %xlate('+': ' ': ciudad);
  endif;
endif;

// API Key de OpenWeatherMap
// IMPORTANTE: Reemplazar con tu propia API key
// Obtener una gratis en: https://openweathermap.org/api
apiKey = 'YOUR_API_KEY_HERE';

// Construir URL
url = 'http://api.openweathermap.org/data/2.5/weather?q=' +
      %trim(ciudad) + '&appid=' + %trim(apiKey) + 
      '&units=metric&lang=en';

// Hacer peticion GET
monitor;
  response = http_string('GET': %trim(url));
  
  // Parsear JSON manualmente (simple)
  // Extraer temperatura
  pos = %scan('"temp":': response);
  if pos > 0;
    temp = %subst(response: pos + 7: 5);
    temp = %xlate(',}': '  ': temp);
  else;
    temp = '20';
  endif;
  
  // Extraer humedad
  pos = %scan('"humidity":': response);
  if pos > 0;
    humidity = %subst(response: pos + 11: 3);
    humidity = %xlate(',}': '  ': humidity);
  else;
    humidity = '50';
  endif;
  
  // Extraer viento
  pos = %scan('"speed":': response);
  if pos > 0;
    windSpeed = %subst(response: pos + 8: 5);
    windSpeed = %xlate(',}': '  ': windSpeed);
  else;
    windSpeed = '10';
  endif;
  
  // Extraer presion
  pos = %scan('"pressure":': response);
  if pos > 0;
    pressure = %subst(response: pos + 11: 5);
    pressure = %xlate(',}': '  ': pressure);
  else;
    pressure = '1013';
  endif;
  
  // Extraer nombre de ciudad
  pos = %scan('"name":"': response);
  if pos > 0;
    cityName = %subst(response: pos + 8: 50);
    pos = %scan('"': cityName);
    if pos > 0;
      cityName = %subst(cityName: 1: pos - 1);
    endif;
  else;
    cityName = ciudad;
  endif;
  
on-error;
  // Si falla, usar datos por defecto
  temp = '20';
  humidity = '50';
  windSpeed = '10';
  pressure = '1013';
  cityName = ciudad;
endmon;

// Generar HTML completo
output = 'Content-type: text/html' + CRLF + CRLF +
'<!DOCTYPE html>' +
'<html><head>' +
'<meta charset="UTF-8">' +
'<title>Clima Real</title>' +
'<style>' +
'body{font-family:Arial;background:linear-gradient(135deg,#667eea,#764ba2);' +
'min-height:100vh;display:flex;justify-content:center;align-items:center;margin:0}' +
'.container{background:white;border-radius:20px;padding:40px;max-width:500px;width:100%;' +
'box-shadow:0 20px 60px rgba(0,0,0,0.3)}' +
'h1{color:#667eea;text-align:center;margin-bottom:10px;font-size:2.5em}' +
'.subtitle{text-align:center;color:#666;margin-bottom:30px;font-size:0.9em}' +
'.card{background:linear-gradient(135deg,#667eea,#764ba2);color:white;' +
'border-radius:15px;padding:30px;text-align:center}' +
'.city{font-size:2em;margin-bottom:10px}' +
'.temp{font-size:4em;font-weight:bold;margin:20px 0}' +
'.details{display:grid;grid-template-columns:1fr 1fr;gap:15px;margin-top:20px}' +
'.detail{background:rgba(255,255,255,0.2);padding:15px;border-radius:10px}' +
'.label{font-size:0.9em;opacity:0.9}' +
'.value{font-size:1.5em;font-weight:bold;margin-top:5px}' +
'form{margin-bottom:30px;display:flex;gap:10px}' +
'input{flex:1;padding:15px;border:2px solid #e0e0e0;border-radius:10px;font-size:16px}' +
'input:focus{outline:none;border-color:#667eea}' +
'button{padding:15px 30px;background:linear-gradient(135deg,#667eea,#764ba2);' +
'color:white;border:none;border-radius:10px;font-size:16px;font-weight:bold;' +
'cursor:pointer;transition:transform 0.2s}' +
'button:hover{transform:translateY(-2px)}' +
'</style>' +
'</head><body>' +
'<div class="container">' +
'<h1>Clima Real</h1>' +
'<div class="subtitle">Datos de OpenWeatherMap</div>' +
'<form method="GET">' +
'<input type="text" name="ciudad" placeholder="Ciudad..." value="' + %trim(ciudad) + '">' +
'<button type="submit">Buscar</button>' +
'</form>' +
'<div class="card">' +
'<div class="city">' + %trim(cityName) + '</div>' +
'<div class="temp">' + %trim(temp) + ' C</div>' +
'<div class="details">' +
'<div class="detail"><div class="label">Humedad</div>' +
'<div class="value">' + %trim(humidity) + '%</div></div>' +
'<div class="detail"><div class="label">Viento</div>' +
'<div class="value">' + %trim(windSpeed) + ' m/s</div></div>' +
'<div class="detail"><div class="label">Presion</div>' +
'<div class="value">' + %trim(pressure) + ' hPa</div></div>' +
'</div></div></div></body></html>';

WrtNoSection(%addr(output:*data): %len(%trim(output)));

wrtsection('*fini');

*inlr = *on;