require 'rails_helper'

RSpec.describe CommentNotifierMailer, type: :mailer do
	describe "created" do
		let(:project) { FactoryGirl.create(:project) }
		let(:ticket_owner) { FactoryGirl.create(:user) }
		let(:ticket) do
			FactoryGirl.create(:ticket, project: project, author: ticket_owner)
		end

		let(:commenter) { FactoryGirl.create(:user) }
		let(:comment) do
			Comment.create(ticket: ticket, author: commenter, text: "Test Comment")
		end

		let(:email) do
			CommentNotifierMailer.created(comment, ticket_owner)
		end

		it "sends out an email notification about a new comment" do
			expect(email.to).to include ticket_owner.email
			title = "#{ticket.name} for #{project.name} has been updated."
			expect(email.body.to_s).to include title
			expect(email.body.to_s).to include "#{commenter.email} wrote:"
			expect(email.body.to_s).to include comment.text
		end
	end
end