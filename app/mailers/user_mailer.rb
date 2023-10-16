class UserMailer < ApplicationMailer
  def auth_mail
    random_number = rand(100000..999999)
    @auth_code = "%06d" % random_number
    email = params[:email]
    mail(to: email, subject: "【使いやすい家計簿】認証コード")
  end
end
