# a wrapper around the FAST api for use with questioning_authority
# API documentation:
# http://www.oclc.org/developer/develop/web-services/fast-api/assign-fast.en.html
require 'rest_client'

class LocalFast

  # https://github.com/projecthydra-labs/questioning_authority#adding-your-own-local-authorities
  # what methods do we need to implement? 
  #   what arguments do they need to accept?
  #   what return values should they have?
  def search q
    #return [{id: 'ponies', label: 'lots of ponies', value: 'in English: lots of ponies'}, {id: 'ponies2', label: 'moar poniez', value: 'in lol: moar poniez'}]
    r = RestClient.get build_query_url(q), { accept: :json }
    results = []
    if r.size < 1
      return results
    end
    JSON.parse(r)['response']['docs'].each do |doc|
      term = doc['suggestall'].first
      if doc['type'] == 'alt'
        term += ' USE ' + doc['auth']
      end
      results << {id: doc['idroot'], label: term, value: doc['auth']}
    end
    return results
  end

  # Not sure why we need this but without it, errors :\
  def initialize(_)
  end

  def build_query_url q
    # not a lot of tolerance for certain chars on the other side
    q.gsub! /-|\(|\)|:/, ""
    escaped_query = URI.escape(q)
    index = 'suggestall'
    return_data = "#{index}%2Cidroot%2Cauth%2Ctype"
    num_rows = 20
    url = "http://fast.oclc.org/searchfast/fastsuggest?&query=#{escaped_query}&queryIndex=#{index}&queryReturn=#{return_data}&suggest=autoSubject&rows=#{num_rows}"
    return url
  end

=begin
suggestall  All facets
suggest00 Personal names
suggest10 Corporate names
suggest11 Event
suggest30 Uniform title
suggest50 Topical
suggest51 Geographic names
suggest55 Form/Genre
=end

end
