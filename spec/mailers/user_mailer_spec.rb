require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#reset_password_email" do
    let(:user) do
      User.create!(
        email: "test@example.com",
        crypted_password: "password",
        salt: "salt",
        reset_password_token: "token"
      )
    end

    let(:mail) { described_class.reset_password_email(user) }

    it "has the correct subject" do
      expect(mail.subject).to eq(
        I18n.t("user_mailer.reset_password_email.subject")
      )
    end

    it "sends to the user's email" do
      expect(mail.to).to eq([user.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to be_present
    end
  end
end
