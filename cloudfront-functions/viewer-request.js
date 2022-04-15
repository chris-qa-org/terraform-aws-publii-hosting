%{ if append_empty_extension != "" ~}
function appendEmptyExtension(filePath, extension) {
  if(filePath != "/" && filePath.indexOf('.') == -1) {
    return filePath.concat("", extension);
  }
  return filePath;
}
%{ endif ~}
function handler(event) {
  // default variables
  var req = event.request;
  var clientIp = event.viewer.ip;

  // set true-client-ip header
  req.headers['true-client-ip'] = {value: clientIp};
  %{~ if append_empty_extension != "" ~}
  // append empty extension
  var newUri = appendEmptyExtension(req.uri, "${append_empty_extension}");
  req.uri = newUri.replace("\/\/", "/", newUri);
  %{~ endif ~}


  // return request
  return req;
}
