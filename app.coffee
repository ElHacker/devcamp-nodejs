formidable = require 'formidable'
http = require 'http'
util = require 'util'
htmlServerPort = 8000
audioServerPort = 8001
clients = []

# render the form to upload files
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

# render the html audio control
routeListen = (req, res) ->
  res.writeHead 200, 'content-type': 'text/html'
  res.end(
    '<h1>Listening</h1>' + 
    "<audio src='http://localhost:#{audioServerPort}' autoplay controls>" + 
    'Your browser does not support the <code>audio</code> element.' +
    '</audio>'
  )

# This route handles all the file upload logic
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
        # Broadcast the data stream
        for client in clients
          client.write data

      part.on 'end', () ->
        console.log "file upload ended"

      part.on 'error', (error) ->
        console.log error

    # Once file has been uploaded
    form.parse req, (err, fields, files) ->
      res.writeHead 200, 'content-type': 'text/plain'
      res.write 'received upload:\n\n'
      # Print files data
      console.log files
      res.end util.inspect(fields: fields, files: files)

# Server to handle the url queries and serves html files
http.createServer( (req, res) ->
  # handle request
  if req.url == '/upload' and req.method.toLowerCase() == 'post'
    routeUpload req, res
  else if req.url == '/listen' and req.method.toLowerCase() == 'get'
    routeListen req, res
  else if req.url == '/' and req.method.toLowerCase() == 'get'
    routeIndex req, res

).listen(htmlServerPort)
console.log "HTML server listening on port #{htmlServerPort}"

# Server to stream audio files on request
http.createServer( (req, res) ->
  # Serve audio files to the http response
  res.writeHead 200, 
    'content-type': 'audio/mpeg'
    'transfer-encoding': 'chunked'
  # Save this listening client to clients array
  clients.push res
  console.log 'Client connected to the stream'
).listen(audioServerPort)
console.log "Audio server listening on port #{audioServerPort}"
