require_relative "user"
require 'net/http'
require 'resolv-replace'
require 'yaml'

require 'rubygems'
require 'json'
##
# Dummy API to simulate behaviors
#


class LoomioAPI

  ##
    # use loomio api to get a handle on the user, which can then be used
    # to get other data from the API

  def initialize

    # Loads from config the API URL.
    @APICommands = YAML.load_file "apiConfig.yaml"
    unless @APICommands[:apiurl]
      raise "api url not correctly defined!"
    end
    @url = @APICommands[:apiurl]

    $stderr.puts "API initialised"
  end

  # Singleton accessor
  def self.api
    if @instance == nil
      @instance = LoomioAPI.new
    end

    return @instance
  end

  # Gets response given the api url and api parameters, and possibly params to post.
  #
  private def getResponse(apiURL, apiParams, params = nil)

    uri = URI(@url + apiURL + apiParams)
    uri.query = URI.encode_www_form(params) if params

    $stderr.puts "sending request to #{uri.to_s}"

    res = Net::HTTP.get_response(uri)

    return res

  end


  # Given a http response, returns an array with the 0th index being the HTTP status (404, 200, 403) and the rest being hash of JSON from response
  #
  private def jsonfy(res)
    if res.is_a?(Net::HTTPNotFound)
      return ['404']
    elsif res.is_a?(Net::HTTPForbidden)
      return ['403']
    elsif res.is_a?(Net::HTTPSuccess)
      jsonObj = ['200'] # adds the '200' in front of the array of hashes
      jsonObj.concat JSON.parse(res.body)

      return jsonObj
    end
  end


  #
  def getUserByNumber(number)
        
        # just returns a new dummy user
        return User.new number
        
    end
    
    
    ##
    # use loomio api to get the list of groups the user is involved in
    # Returns nothing if no groups
    #
  def getUserGroups(user)
        
        # returns dummy list
        return ["Team Aqua", "Team Magma", "Team Rocket", "Team xX420BL4Z3Xx", "Test Group"]
        
    end
    
    
    
    ##
    # Gets info about the given group in the loomio database relative to that user.
    #
  def getGroupStatus(user)
    	
    	# sample output
    	return 'public'
    	
    	# return 'private'
    	
    	# return 'invalid'
    end
    
    ##
    # use loomio api to get the list of groups the user is involved in
    # Returns nothing if no groups
    #
  def getSubscribedGroups(user)
        
        # returns dummy list
        return ["Team Aqua", "Team Magma"]
        
    end
    
    ##
    # Returns an array of ongoing discussions in the group
    #


    # Gets an array of proposals in JSON format when given a subdomain name. The first member of the array is status code of whether the request was successful
  #
  #####################################################################################################################################################################################################################################################################
  def getProposalsBySubdomain(subdomain)
    res = getResponse("active_proposals/", subdomain)

    return jsonfy(res)
  end

  #
  # Gets a single JSON representation of the latest proposal given the key of the group. returns array, whose first element is status code.
  #
  def getLatestProposalByKey(key)
    res = getResponse("proposals/", key)
    res.body = "[#{res.body}]"

    return jsonfy(res)
  end

  #####################################################################################################################################################################################################################################################################


    ##
    # use loomio api to unsubscribe the user from the given group
    # 
    #
  def unsubscribeFromGroup(user, group)
        
        # returns result of API call or success
        return 'success'
        
    end
    
    ##
    # use loomio api to subscribe the user to the given group
    #
  def subscribeToGroup(user, group)
        
        # returns result of API call or success
        return 'success'
        
    end
    
    
    
    ##
    # use loomio api to get stuff the user has recently been involved in.
    #
  def getUserSummary(user)
        
        # Returns a sample summary
        return "Nothing happened in any of the groups you care about. You can charge your iPhone with a microwave now though, pretty neat."

  end


  # Gets the proposal summary by key
  def getProposalSummary(key)

    arr = getLatestProposalByKey(key)

    if arr[0] == "200" # if key exists
      hash = arr[1]

      # returns array in the order of yes,no,abstain,block
      return [hash["yes_votes_count"], hash["no_votes_count"], hash["abstain_votes_count"], hash["block_votes_count"]]
    end

    return nil


  end

  # Gets the latest proposals of the given subdomain
  def getGroupDiscussions(group)


    hash = getProposalsBySubdomain(group)

    if hash.shift == "200"
      output = Array.new

      hash.each do |x|
        output << x["name"]
      end

      return output
    end

    return nil

    #return ["World Domination", "Funniest Cat Picture", "An Interesting Discussion"]

  end


  ##
    # use loomio api to get stuff the user has recently been involved in.
    #
  def getPollSummary(poll)
        
        # Returns a sample summary
        return %Q(The <#{poll}> positions are
Agree		=	<50%>
Disagree	=	<80%>
Abstain		=	<10%>
Block		=	<3%>)
    end

end

#testing purposes
def test

  puts LoomioAPI.api.getGroupDiscussions("abstainers")

  puts LoomioAPI.api.getProposalSummary("xEtj48Rz").to_s

  # puts LoomioAPI.api.getProposalsBySubdomain("abstainers").to_s

  #puts LoomioAPI.api.getLatestProposalByKey("xEtj48Rz").to_s

end

#test