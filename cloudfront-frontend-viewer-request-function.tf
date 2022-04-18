data "template_file" "cloudfront_frontend_viewer_request_function" {
  template = file("${path.module}/cloudfront-functions/viewer-request.js")

  vars = {
    append_empty_extension = local.enable_publii_pretty_urls ? "/index.html" : ""
  }
}

resource "aws_cloudfront_function" "frontend_viewer_request" {
  name    = "frontend-viewer-request-${local.project_name}"
  runtime = "cloudfront-js-1.0"
  comment = "frontend viewer-request function"
  publish = true
  code    = data.template_file.cloudfront_frontend_viewer_request_function.rendered
}
