##
# Makes a new command to show the user a Proposal
#
# viewProposal <Proposal number>
class ViewProposal < Command
	# Overrides base in Command
	def self.process(message)
		# Remove the command name from the message
		message.msg.slice! 0..name.size
		propNum = message.msg
		propNum = Database.getKey(message.num, propNum)

		return Message.new message.num, 
			"That proposal number is not recognised. Please use ViewGroup to find "\
			"the proposal you're looking for.\n"\
			"ViewGroup <subdomain>" if propNum.nil?

		# Making a call to the API giving it a proposal number and getting a proposal 
		status, proposal = LoomioAPI.getProposalByKey propNum
		
		return Message.new message.num, "The proposal does not exist" unless status == 200

		percentAgree	=	MessageHelper.percentage proposal["yes_votes_count"], proposal["votes_count"]		
		percentDisagree =	MessageHelper.percentage proposal["no_votes_count"], proposal["votes_count"]
		percentAbstain	=	MessageHelper.percentage proposal["abstain_votes_count"], proposal["votes_count"]
		percentBlock	=	MessageHelper.percentage proposal["block_votes_count"], proposal["votes_count"]
		totalVotes		=	proposal["votes_count"]
		
		# This is where the user is told the outcome of their command
		return Message.new message.num, 
			"The current positions for #{proposal["name"]} are:\n"\
			"Agree		=	#{percentAgree}%\n"\
			"Disagree	=	#{percentDisagree}%\n"\
			"Abstain	=	#{percentAbstain}%\n"\
			"Block		=	#{percentBlock}%\n"\
			"Total number of votes = #{totalVotes}"
	end
end
