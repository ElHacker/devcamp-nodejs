formidable = require 'formidable'
http = require 'http'
util = require 'util'
port = 8000

http.createServer( (req, res) ->
  # handle request
  if req.url == '/upload' and req.method.toLowerCase() == 'post'
    # parse file and upload
    form = new formidable.IncomingForm()

    form.parse req, (err, fields, files) ->
      res.writeHead 200, 'content-type': 'text/plain'
      res.write 'received upload:\n\n'
      # Print files data
      console.log files
      res.end util.inspect(fields: fields, files: files)

    return

  # show a file upload form
  res.writeHead 200, 'content-type': 'text/html'
  res.end(
    '<form action="/upload" enctype="multipart/form-data" method="post">'+
    '<input type="text" name="title"><br>'+
    '<input type="file" name="upload" multiple="multiple"><br>'+
    '<input type="submit" value="Upload">'+
    '</form>'
  )
).listen(port)
console.log "Server listening on port #{port}"
