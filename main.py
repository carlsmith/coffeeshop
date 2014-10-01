import webapp2

class Index(webapp2.RequestHandler):

    index = open('index.html').read()
    def get(self): self.response.write(self.index)

app = webapp2.WSGIApplication(routes=[(r'/', Index)])
