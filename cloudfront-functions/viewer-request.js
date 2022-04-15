function handler(event) {
  // default variables
  var req = event.request;
  var clientIp = event.viewer.ip;

  // set true-client-ip header
  req.headers['true-client-ip'] = {value: clientIp};

  // return request
  return req;
}
