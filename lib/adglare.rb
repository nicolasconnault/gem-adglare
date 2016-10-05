class Adglare
  require 'digest/sha1'
  require 'curb'
  require 'json'
  require 'byebug'

  attr_accessor :public_key, :private_key, :ajax
  # If ajax is true, the class will output the required Javascript to make the API call, instead of using CURL

  def initialize public_key:, private_key:, ajax:false
    self.public_key = public_key
    self.private_key = private_key
    self.ajax = ajax
  end
  
  # param int zgID Zone Group ID
  def zonegroups_list zgID: nil  
    call_adglare_api 'zonegroups_list', { zgID: zgID } 
  end
  
  # param string name Zone name
  def zonegroups_add name:  
    call_adglare_api 'zonegroups_add', { name: name }
  end
 
  # param int zgID Zone Group ID
  def zonegroups_delete zgID:  
    call_adglare_api 'zonegroups_delete', { zgID: zgID }
  end
  
  # param int zID Zone ID
  # param int zgID Zone Group ID
  def zones_list zID: nil, zgID: nil  
    call_adglare_api 'zones_list', {zId: zID, zgID: zgID}
  end

  # param string name Zone name
  # param int zgID Zone Group ID
  # param string adtype Ad type (jsonad or imagebanner)
  def zones_add name:, zgID:, adtype: 
    call_adglare_api 'zones_add', {zgID: zgID, adtype: adtype, name: name}
  end
  
  # param int zID Zone ID
  # param string name Zone name
  # param string adformat The supported ad dimensions, in the format iab_000_000. Delimit and flag by a # if multiple dimensions are supported. example: #iab_468_60#iab_300_250#
  # param int zgID Zone Group ID
  def zones_modify zID:, name: nil, adformat: nil, zgID: nil 
    call_adglare_api 'zones_modify', {zID: zID, zgID: zgID, adformat: adformat, name: name}
  end
  
  # param int zID Zone ID
  def zones_delete zID: 
    call_adglare_api 'zones_delete', {zID: zID}
  end
  
  # param int cID Campaign ID
  # param int aID Advertiser ID
  def campaigns_list cID: nil, aID: nil 
    call_adglare_api 'campaigns_list', {cID: cID, aID: aID}
  end
  
  # param string name Campaign name
  def campaigns_add name:
    call_adglare_api 'campaigns_add', {name: name}
  end
  
   # param int cID Campaign ID
   # param array params at least one of the following:
   #      int     aID                 (advertiser ID)
   #      string  timestamp_start     (can be set to "immediately") example: 2015-12-03 15:59:59
   #      string  runsuntil           example: 2015-12-03 15:59:59
   #      string  name
   #      string  status              (active, onhold, waitingreview, completed)
   #      int     weight              (1-5)
   #      int     tier                (1 for an In-House campaign, 2 for Normal and 3 for Override)
   #      string  displaynetwork      (which zones this campaign should run. Use "#ALL#" to display in all zones, or delimit the zIDs by a # otherwise)
   #      string  notes
   #      string  notes_updatemethod  (overwrite, append, prepend) defaults to append
  def campaigns_modify cID:, params: [] 
    call_adglare_api 'campaigns_modify', params + {cID: cID}
  end

  
   # param int cID Campaign ID
  def campaigns_delete cID: 
    call_adglare_api 'campaigns_delete', {cID: cID}
  end

  
   # param int cID Campaign ID
  def campaigns_creatives_list cID:
    call_adglare_api 'campaigns_creatives_list', {cID: cID}
  end

  
   # param int cID Campaign ID
   # param string creativename
   # param string bannerURL The URL on which the banner can be found.
   # param string targetURL The landing page URL that should be opened upon clicking
  def campaigns_creatives_add cID:, creativename:, bannerURL:, targetURL: 
    call_adglare_api 'campaigns_creatives_add', {cID: cID, creativename: creativename, bannerURL: bannerURL, targetURL: targetURL}
  end

  
   # param int cID Campaign ID
   # param int crID Campaign Creative ID
   # param string creativename
   # param string targetURL The landing page URL that should be opened upon clicking
  def campaigns_creatives_modify cID:, crID:, creativename: nil, targetURL: nil
    call_adglare_api 'campaigns_creatives_modify', {cID: cID, creativename: creativename, crID: crID, targetURL: targetURL}
  end

  
   # param int cID Campaign ID
   # param int crID Campaign Creative ID
  def campaigns_creatives_delete cID:, crID: 
    call_adglare_api 'campaigns_creatives_delete', {cID: cID, crID: crID}
  end

  
   # param int cID Campaign ID
   # param string date_from The start date of the result set. Use the format YYYY-MM-DD
   # param string date_until The end date of the result set. Use the format YYYY-MM-DD
  def reports_campaigns date_from:, date_until:, cID: nil
    call_adglare_api 'reports_campaigns', {date_from: date_from, date_until: date_until, cID: cID}
  end

  
   # param int zID Zone ID
   # param string date_from The start date of the result set. Use the format YYYY-MM-DD
   # param string date_until The end date of the result set. Use the format YYYY-MM-DD
  def reports_zones date_from:, date_until:, zID: nil
    call_adglare_api 'reports_zones', {date_from: date_from, date_until: date_until, zID: zID}
  end

  private

    def call_adglare_api method_name, post_vars
      # remove empty values from post_vars
      post_vars.select! do |k, v|
        v != nil
      end

      # add your authentication pairs 
      post_vars[:public_key] = self.public_key
      post_vars[:nonce] = sprintf('%.0f', (Time.now.to_f * 100).round)
      post_vars[:hash_method] = 'sha1'

      # generate authentication hash variable
      query_string = URI.encode(post_vars.map{|k,v| "#{k}=#{v}"}.join("&"))
      to_be_hashed = self.private_key + '_' + query_string
      hash = Digest::SHA1.hexdigest to_be_hashed
      post_vars[:hash] = hash

      endpoint = 'https://healthpoint.adglare.net/api/v1/'
      url = endpoint + method_name

      if self.ajax 
        query_string = URI.encode(post_vars.map{|k,v| "#{k}=#{v}"}.join("&"))
        return "
            $.ajax({type: 'POST', dataType: 'jsonp', url: '#{endpoint}?', data: '#{query_string}', xhrFields: {withCredentials: false}, success: function(data) {
                [[callback]]
            }
        });"
      else 
        # send via cURL
        http = Curl.post(url, post_vars) do |http|
          http.headers = false
        end

        content = http.body_str

        # parse response into JSON object
        json = JSON.parse content
        
        if json["response"]["success"] == '1' || json["response"]["errormsg"] == "No results with these filters."
          if json["response"]["data"]
            return json["response"]["data"]
          elsif json["response"]["errormsg"] == "No results with these filters."
            return []
          else 
            return json["response"]
          end
        else 
          raise AuthenticationError, json["response"]["errormsg"]
        end
      end
    end
end

class AuthenticationError < StandardError
end
