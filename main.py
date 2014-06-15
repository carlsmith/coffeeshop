import webapp2

class Index(webapp2.RequestHandler):

    index = open('index.html').read()

    def get(self): self.response.write(self.index)

class ChromeStoreCode(webapp2.RequestHandler):

    def get(self): self.response.write(
        'google-site-verification: googlea443e567cbbd9e03.html'
        )

app = webapp2.WSGIApplication(
    routes=[
        (r'/', Index),
        (r'/googlea443e567cbbd9e03.html', ChromeStoreCode)
        ])
