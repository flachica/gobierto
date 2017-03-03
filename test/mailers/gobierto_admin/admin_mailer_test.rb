require "test_helper"

module GobiertoAdmin
  class AdminMailerTest < ActionMailer::TestCase
    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_confirmation_instructions
      email = AdminMailer.confirmation_instructions(admin).deliver_now

      refute ActionMailer::Base.deliveries.empty?

      assert_equal ["admin@gobierto.dev"], email.from
      assert_equal ["admin@gobierto.dev"], email.reply_to
      assert_equal [admin.email], email.to
      assert_equal "Activate your account at Gobierto", email.subject
    end

    def test_invitation_instructions
      email = AdminMailer.invitation_instructions(admin).deliver_now

      refute ActionMailer::Base.deliveries.empty?

      assert_equal ["admin@gobierto.dev"], email.from
      assert_equal ["admin@gobierto.dev"], email.reply_to
      assert_equal [admin.email], email.to
      assert_equal "You have been invitited to collaborate in Gobierto", email.subject
    end

    def test_reset_password_instructions
      email = AdminMailer.reset_password_instructions(admin).deliver_now

      refute ActionMailer::Base.deliveries.empty?

      assert_equal ["admin@gobierto.dev"], email.from
      assert_equal ["admin@gobierto.dev"], email.reply_to
      assert_equal [admin.email], email.to
      assert_equal "Reset password instructions", email.subject
    end
  end
end
