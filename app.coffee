formidable = require 'formidable'
http = require 'http'
util = require 'util'
port = 8000
clients = []


routeIndex = (req, res) ->
  # show a file upload form
  res.writeHead 200, 'content-type': 'text/html'
  res.end(
    '<form action="/upload" enctype="multipart/form-data" method="post">'+
    '<input type="text" name="title"><br>'+
    '<input type="file" name="upload" multiple="multiple"><br>'+
    '<input type="submit" value="Upload">'+
    '</form>'
  )

routeUpload = (req, res) ->
    # parse file and upload
    form = new formidable.IncomingForm()

    # Override the onPart method to access the multipart stream
    form.onPart = (part) ->
      if (!part.filename)
        # let formidable handle all non-file parts
        form.handlePart part
        return

      part.on 'data', (data) ->
        # Handle the data stream
        console.log data

      part.on 'end', () ->
        console.log "file upload ended"

      part.on 'error', (error) ->
        console.log error

    form.parse req, (err, fields, files) ->
      res.writeHead 200, 'content-type': 'text/plain'
      res.write 'received upload:\n\n'
      # Print files data
      console.log files
      res.end util.inspect(fields: fields, files: files)

http.createServer( (req, res) ->
  # handle request
  if req.url == '/upload' and req.method.toLowerCase() == 'post'
    routeUpload req, res
  else if req.url == '/' and req.method.toLowerCase() == 'get'
    routeIndex req, res

).listen(port)
console.log "Server listening on port #{port}"
