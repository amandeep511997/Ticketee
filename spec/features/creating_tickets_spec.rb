require "rails_helper"

RSpec.feature "User can create new tickets" do
	let(:user) { FactoryGirl.create(:user) } # ** Ch-6
	let!(:state) { FactoryGirl.create(:state, name: "New", default: true) }

	before do
		login_as(user) # ** ch-6
		project = FactoryGirl.create(:project, name: "Internet Explorer")
		assign_role!(user, :manager, project)

		visit project_path(project)
		click_link "New Ticket"
	end

	scenario "with valid attributes" do
		fill_in "Name", with: "Non-standard compliance"
		fill_in "Description", with: "My pages are ugly!"
		click_button "Create Ticket"

		expect(page).to have_content "Ticket has been created."
		expect(page).to have_content "State: New"

		# ** done after associations - Ch-6
		within("#ticket") do
			expect(page).to have_content("Author: #{user.email}")
		end

	end

	scenario "when providing invalid attributes" do
		click_button "Create Ticket"

		expect(page).to have_content "Ticket has not been created."
		expect(page).to have_content "Name can't be blank"
		expect(page).to have_content "Description can't be blank"

	end

	scenario "with an invalid description" do
		fill_in "Name", with: "Non-standard compliance"
		fill_in "Description", with: "It sucks"
		click_button "Create Ticket"

		expect(page).to have_content "Ticket has not been created."
		expect(page).to have_content "Description is too short"
	end

	scenario "with an attachments" do
		fill_in "Name", with: "Add documentation for blink tag"
		fill_in "Description", with: "The blink tag has a speed attribute"

		attach_file "File #1", Rails.root.join("spec/fixtures/speed.txt")
		click_button "Create Ticket"

		expect(page).to have_content("Ticket has been created")

		within("#ticket .attachments") do
			expect(page).to have_content "speed.txt"
		end
	end

	scenario "persisting file uploads across form displays" do
		attach_file "File #1", "spec/fixtures/speed.txt"
		click_button "Create Ticket"

		fill_in "Name", with: "Add documentation for blink tag"
		fill_in "Description", with: "The blink tag has a speed attribute"
		click_button "Create Ticket"

		within("#ticket .attachments") do
			expect(page).to have_content "speed.txt"
		end
	end

	scenario "with associated tags" do
		fill_in "Name", with: "Non-standard compliance"
		fill_in "Description", with: "My pages are ugly!"
		fill_in "Tags", with: "browser visual"
		click_button "Create Ticket"

		expect(page).to have_content "Ticket has been created."
		within("#ticket #tags") do
			expect(page).to have_content "browser"
			expect(page).to have_content "visual"
		end
	end

end